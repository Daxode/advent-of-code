package dir_notifs

import "core:sys/windows"
import "core:fmt"
import "core:path/filepath"
import "core:mem"
import "core:runtime"
import "core:thread"


main :: proc() {
    subscribe_to_directory_service("../dir_notifs", false, proc(action: FileAction, filename: string) {
        fmt.println(sep="", args={action, ": ", filename})
    })
    
    for {
        fmt.println("Sleeping...")
        windows.Sleep(1000)
    }
}

subscribe_to_directory_service :: proc(path_relative: string, include_subdirs: bool,
                                       OnChangeProc: proc(FileAction, string), 
                                       file_notify_changes: FileNotifyChanges = {.LAST_WRITE, .CREATION, .FILE_NAME}) {
    Data :: struct{path_relative: string, include_subdirs: bool, OnChangeProc: proc(FileAction, string), file_notify_changes: FileNotifyChanges}
    data := new(Data)
    data.path_relative = path_relative
    data.include_subdirs = include_subdirs
    data.OnChangeProc = OnChangeProc
    data.file_notify_changes = file_notify_changes
    t := thread.create_and_start_with_poly_data(data, proc(data: ^Data) {
        subscribe_to_directory_service_thread_stopping(data.path_relative, data.include_subdirs, data.OnChangeProc, data.file_notify_changes)
	})
}

@private
subscribe_to_directory_service_thread_stopping :: proc(path_relative: string, include_subdirs: bool,
                                                        OnChangeProc: proc(FileAction, string), 
                                                        file_notify_changes: FileNotifyChanges = {.LAST_WRITE, .CREATION, .FILE_NAME}) -> b8 {
    path_absolute, path_absolute_ok := filepath.abs(path_relative)
    if (!path_absolute_ok) {return false}
    path_wide := windows.utf8_to_wstring(path_absolute)
    dir_handle := windows.CreateFileW(path_wide, windows.FILE_LIST_DIRECTORY, 
        windows.FILE_SHARE_READ | windows.FILE_SHARE_WRITE | windows.FILE_SHARE_DELETE,
        nil, windows.OPEN_EXISTING, windows.FILE_FLAG_BACKUP_SEMANTICS | windows.FILE_FLAG_OVERLAPPED,
        nil)
        
    file_info_data: [1000]u8
    read_directory_changes_ok := read_directory_changes(dir_handle, &file_info_data, file_notify_changes, include_subdirs)
    if !read_directory_changes_ok {return false}
    
    for {
        switch windows.WaitForSingleObject(dir_handle, windows.INFINITE) {
            case windows.WAIT_OBJECT_0:
                file_info := (transmute(^windows.FILE_NOTIFY_INFORMATION)&file_info_data)
                for {
                    file_name, _ := windows.wstring_to_utf8(&file_info.file_name[0], int(file_info.file_name_length)/size_of(windows.wchar_t))
                    OnChangeProc(FileAction(file_info.action), file_name)

                    if file_info.next_entry_offset != 0 {
                        file_info = transmute(^windows.FILE_NOTIFY_INFORMATION)mem.ptr_offset(transmute(^u8)file_info, file_info.next_entry_offset)
                    } else {
                        break
                    }
                }
                read_directory_changes_ok = read_directory_changes(dir_handle, &file_info_data, file_notify_changes, include_subdirs)
                if !read_directory_changes_ok {return false}
        }
    }

    read_directory_changes :: proc(dir_handle: windows.HANDLE, file_info_data: ^[1000]u8, file_notify_changes: FileNotifyChanges, include_subdirs: bool) -> b8 {
        overlapped: windows.OVERLAPPED
        dw_bytes: windows.DWORD
        return b8(windows.ReadDirectoryChangesW(dir_handle, rawptr(file_info_data), len(file_info_data), windows.BOOL(include_subdirs), 
        transmute(windows.DWORD)file_notify_changes,
        &dw_bytes, &overlapped, nil))
    }
}

FileNotifyChanges :: bit_set[FileNotifyChange; windows.DWORD]

FileNotifyChange :: enum {
    FILE_NAME   = 0,
    DIR_NAME    = 1,
    ATTRIBUTES  = 2,
    SIZE        = 3,
    LAST_WRITE  = 4,
    LAST_ACCESS = 5,
    CREATION    = 6,
    SECURITY    = 8,
}

FileAction :: enum {
    ADDED = windows.FILE_ACTION_ADDED,
    REMOVED = windows.FILE_ACTION_REMOVED,
    MODIFIED = windows.FILE_ACTION_MODIFIED,
    RENAMED_OLD_NAME = windows.FILE_ACTION_RENAMED_OLD_NAME,
    RENAMED_NEW_NAME = windows.FILE_ACTION_RENAMED_NEW_NAME,
}