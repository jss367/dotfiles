# SSH terminal coloring
# Tints the background and updates the tab title when SSHing into a remote box.
# Works in both WezTerm (OSC 11/111) and iTerm2.

ssh() {
    printf '\033]11;#3d0000\007'       # dark red background tint
    printf '\033]0;ssh: %s\007' "$1"   # tab title = "ssh: <host>"
    command ssh "$@"
    printf '\033]111;\007'             # restore default background
    printf '\033]0;local\007'          # reset tab title
}
