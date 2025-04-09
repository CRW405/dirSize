if [ -d "$1" ]; then # if there is a directory passed as the first argument:
    dir=$1 # set it as the directory,
else # else set it to the current directory
    dir=$(pwd)
fi

if [ "$2" ]; then # if there is a second argument: set it as the depth, else set it to 1
    depth=$2
else
    depth=1
fi

echo "$dir: $(du -sh $dir | awk '{print $1}')" # print the size of the selected directory


list_dir() {
    local dir=$1 # directory to list
    local current_depth=$2 # keeping track of where we are depthwise
    local prefix=$3 # saving prefix so that everything lines up properly
    
    if [ "$current_depth" -le "$depth" ]; then # if we are within the depth limit
        local subdirs=() # array to hold subdirectories
        for item in "$dir"/.* "$dir"/*; do # for subdir in dir:
            [ -d "$item" ] && subdirs+=("$item") # if it is a directory, add it to the array
        done
        
        local total=${#subdirs[@]} # total number of subdirectories
        local count=0 # counter for the current subdirectory
        
        for sub in "${subdirs[@]}"; do # for each subdirectory's subdirectory
            if [ -d "$sub" ]; then # if it is a directory, count it
                count=$((count + 1))
                
                if [ "$count" -eq "$total" ]; then # if it is the last subdirectory
                    local symbol="└──>" # use this arrow
                    local new_prefix="${prefix}     " # update the prefix
                else
                    local symbol="├──>" # if not the last, use this arrow
                    local new_prefix="${prefix}│    "
                fi
                
                name=$(basename "$sub" 2>/dev/null) # get the name of the subdirectory as long as it is not null
                if [ $? -ne 0 ]; then # if there is an error, set name to "Name Error"
                    name="Name Error"
                fi
                
                size=$(du -sh "$sub" 2>/dev/null | awk '{print $1}') # get the size of the subdirectory as long as it is not null
                if [ $? -ne 0 ]; then # if there is an error, set size to "Size Error"
                    size="Size Error"
                fi
                
                echo "${prefix}${symbol} ${name}: ${size}" # print the name and size of the subdirectory
                list_dir "$sub" $((current_depth + 1)) "$new_prefix" # call the function recursivelyto work our way down to specified depth
            fi
        done
    fi
}

list_dir "$dir" 1 # make initial call with inputted directory and starting depth
