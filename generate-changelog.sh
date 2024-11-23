function print_list {
    title="$1"
    messages="$2"

    if [ -z "$messages" ]; then
        return
    fi

    echo -e "# $title\n"

    IFS=$'\n'
    for line in $messages; do
        echo "$line"
    done

    echo
}

prev_ver=$(git tag --sort=-creatordate | head -2 | tail -1)
current_ver=$(git tag --sort=-creatordate | head -1)
commits=$(git log $prev_ver..$current_ver --format='- %s' | grep -v 'release:') 

echo -e "**Changes from the last release:** https://github.com/programotuojes/finances/compare/$prev_ver...$current_ver\n"

print_list 'Breaking changes' "$(grep '!:' <<< $commits)"
print_list 'Features' "$(grep 'feat:' <<< $commits)"
print_list 'Fixes' "$(grep 'fix:' <<< $commits)"
print_list 'Other' "$(grep -Ev '!:|feat:|fix:' <<< $commits)"
