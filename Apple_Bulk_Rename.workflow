on run {input, parameters}
    -- Prompt user for delimiter
    set delimiters to {"Underscore (_)", "Dash (-)", "Dot (.)"}
    set selected_delimiter to choose from list delimiters with prompt "Choose the delimiter for filenames:" default items {"Underscore (_)"} without multiple selections allowed
    if selected_delimiter is false then return input
    
    set new_delimiter to "_"
    if (selected_delimiter as text) contains "Dash" then set new_delimiter to "-"
    if (selected_delimiter as text) contains "Dot" then set new_delimiter to "."
    
    -- Prompt user for capitalization
    set capitalization_options to {"Capitalize Each Word", "Preserve Original Casing"}
    set selected_capitalization to choose from list capitalization_options with prompt "Choose capitalization style:" default items {"Capitalize Each Word"} without multiple selections allowed
    if selected_capitalization is false then return input
    
    set should_capitalize to (selected_capitalization as text = "Capitalize Each Word")
    
    -- Process each file from input
    try
        tell application "Finder"
            repeat with a_file in input
                set a_item to a_file
                set file_name_with_ext to name of a_item
                set parent_folder to container of a_item
                set parent_posix to POSIX path of (parent_folder as alias)
                
                -- Simple filename splitting
                set name_length to length of file_name_with_ext
                set last_dot_pos to 0
                repeat with i from name_length to 1 by -1
                    if character i of file_name_with_ext is "." then
                        set last_dot_pos to i
                        exit repeat
                    end if
                end repeat
                
                if last_dot_pos > 0 then
                    set base_name to text 1 thru (last_dot_pos - 1) of file_name_with_ext
                    set file_ext to text last_dot_pos thru -1 of file_name_with_ext
                else
                    set base_name to file_name_with_ext
                    set file_ext to ""
                end if
                
                -- Clean and capitalize
                set cleaned_name to my clean_base_name(base_name, new_delimiter)
                
                if should_capitalize then 
                    set cleaned_name to (do shell script "echo " & quoted form of cleaned_name & " | awk '{for(i=1;i<=NF;i++){sub(/./,toupper(substr($i,1,1)),$i)}}1' OFS='" & new_delimiter & "'")
                end if
                
                -- Create new filename
                set new_file_name to cleaned_name & file_ext
                
                -- Only rename if the filename is different
                if new_file_name is not file_name_with_ext then
                    -- Handle conflicts by appending numeric suffix
                    set temp_new_file_name to new_file_name
                    set temp_new_file_path to parent_posix & temp_new_file_name
                    
                    set conflict_count to 1
                    repeat while (do shell script "test -e " & quoted form of temp_new_file_path & " && echo 1 || echo 0") is "1"
                        set temp_new_file_name to cleaned_name & "_" & conflict_count & file_ext
                        set temp_new_file_path to parent_posix & temp_new_file_name
                        set conflict_count to conflict_count + 1
                    end repeat
                    
                    -- Rename the file
                    set name of a_item to temp_new_file_name
                end if
            end repeat
        end tell
        
    on error errMsg
        display dialog "Error: " & errMsg
    end try
    
    return input
end run

-- Utility handler: find position of last dot in filename
on find_last_dot(file_name)
    set name_length to length of file_name
    repeat with i from name_length to 1 by -1
        if character i of file_name is "." then
            return i
        end if
    end repeat
    return 0
end find_last_dot

-- Utility handler: clean base name (replace non-alphanumerics with delimiter, collapse repeats)
on clean_base_name(base_name, delimiter)
    set cleaned_name to ""
    set was_delimiter to false
    repeat with i from 1 to length of base_name
        set c to character i of base_name
        if c is in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" then
            set cleaned_name to cleaned_name & c
            set was_delimiter to false
        else
            if not was_delimiter then
                set cleaned_name to cleaned_name & delimiter
                set was_delimiter to true
            end if
        end if
    end repeat
    -- Remove trailing delimiter
    if length of cleaned_name > 0 then
        if character -1 of cleaned_name is delimiter then set cleaned_name to text 1 thru -2 of cleaned_name
    end if
    return cleaned_name
end clean_base_name
