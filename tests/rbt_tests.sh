#!/bin/bash

cd $(dirname $(readlink -f $0))

total=0
ok=0
ko=0

function assert_equals() {
    total=$((total+1))
    expected="$1"
    actual="$2"
    message="$3"
    if [[ "$expected" == "$actual" ]]; then
        ok=$((ok+1))
        echo "OK: ${message}" >&2
    else
        ko=$((ko+1))
        echo "KO: ${message}" >&2
        echo "   expects: ${expected}" >&2
        echo "   but receives: ${actual}" >&2
    fi
}

function assert_exec_equals() {
    command="${1}"
    actual=$(eval "${command}")
    expected="${2}"
    assert_equals "${expected}" "${actual}" "${command}"

}

## No tags, no change

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ipsum dolor sit amet.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem ipsum dolor sit amet.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}"

rm -f /tmp/lorem_ipsum

## Tags, monoline

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit amet.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit amet.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}"

rm -f /tmp/lorem_ipsum

## Tags, monoline

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit *BEGIN*amet*END*.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit *BEGIN*new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}"

rm -f /tmp/lorem_ipsum


## Tag multiline

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*Pellentesque maximus faucibus lectus, in ultricies lorem volutpat in.
Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus.
Praesent in justo et ante faucibus eleifend in ac est. Donec orci magna, pellentesque id libero nec, faucibus porta purus.
Pellentesque luctus sollicitudin tortor sit amet accumsan. Nullam mauris felis, egestas in faucibus in, feugiat vel arcu.
*END*Cras rhoncus aliquam tristique.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*new text here
*END*Cras rhoncus aliquam tristique.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}"

## Tag multiline

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*
Pellentesque maximus faucibus lectus, in ultricies lorem volutpat in.
Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus.
Praesent in justo et ante faucibus eleifend in ac est. Donec orci magna, pellentesque id libero nec, faucibus porta purus.
Pellentesque luctus sollicitudin tortor sit amet accumsan. Nullam mauris felis, egestas in faucibus in, feugiat vel arcu.
*END*
Cras rhoncus aliquam tristique.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit. *BEGIN*
new text here*END*
Cras rhoncus aliquam tristique.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}"


echo "${ok}/${total} (${ko} errors)"

#rm -f /tmp/lorem_ipsum

if [[ ${ok} -ne ${total} ]]; then
    exit 1
else
    exit 0
fi
