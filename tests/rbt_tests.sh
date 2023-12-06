#!/bin/bash

cd $(dirname $(readlink -f $0))

total=0
ok=0
ko=0

function assert_equals() {
    total=$((total+1))
    expected="$1"
    actual="$2"
    command="$3"
    message="$4"
    if [[ "$expected" == "$actual" ]]; then
        ok=$((ok+1))
        echo "OK: ${message}" >&2
    else
        ko=$((ko+1))
        echo "KO: ${message}" >&2
        echo "   command: ${command}" >&2
        echo "   expects: ${expected}" >&2
        echo "   but receives: ${actual}" >&2
    fi
}

function assert_exec_equals() {
    command="${1}"
    actual=$(eval "${command}")
    expected="${2}"
    message="${3}"
    assert_equals "${expected}" "${actual}" "${command}" "${message}"

}

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ipsum dolor sit amet.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem ipsum dolor sit amet.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}"  \
    "#1: No block, no change"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit amet.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit amet.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#2: Block on one line"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit *BEGIN*amet*END*.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit *BEGIN*new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#3: Two blocks on the same line"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit amet, consectetur
*BEGIN*adipiscing elit*END*.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit amet, consectetur
*BEGIN*new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#4: Two blocks on consecutive lines"


################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit
amet,
consectetur *BEGIN*adipiscing elit*END*.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit
amet,
consectetur *BEGIN*new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#5: Two blocks on non consecutive lines"

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit
amet,
consectetur *BEGIN*
adipiscing elit*END*.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit
amet,
consectetur *BEGIN*
new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#6: Two blocks on non consecutive lines. The second block is on two lines (force LF after begin)"


################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit
amet,
consectetur *BEGIN*
adipiscing
elit
*END*.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit
amet,
consectetur *BEGIN*
new text here
*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#7: Two blocks on non consecutive lines. The second block is on two lines (force LF after begin and before end)"


################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor *END*sit
amet, consectetur
*BEGIN*
adipiscing
elit *END*.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here*END*sit
amet, consectetur
*BEGIN*
new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#8: Two blocks on non consecutive lines. The second block is on two lines (force LF after begin)"


################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem *BEGIN*ipsum dolor
*END*sit amet, consectetur *BEGIN*
adipiscing
elit *END*.
EOF


read -r -d '' EXPECTED <<'EOF'
Lorem *BEGIN*new text here
*END*sit amet, consectetur *BEGIN*
new text here*END*.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#9: Two blocks with end of the first block/begin of the second block are on the same line"


################################################################################################################

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
new text here
*END*
Cras rhoncus aliquam tristique.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '*BEGIN*' -e '*END*' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#10: One block on several lines"

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ~ipsum dolor~ sit amet.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem ~new text here~ sit amet.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '~' -e '~' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#11: Block on one line (begin and end strings are equal)"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit. ~
Pellentesque maximus faucibus lectus, in ultricies lorem volutpat in.
Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus.
Praesent in justo et ante faucibus eleifend in ac est. Donec orci magna, pellentesque id libero nec, faucibus porta purus.
Pellentesque luctus sollicitudin tortor sit amet accumsan. Nullam mauris felis, egestas in faucibus in, feugiat vel arcu.
~
Cras rhoncus aliquam tristique.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit. ~
new text here
~
Cras rhoncus aliquam tristique.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '~' -e '~' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#12: Block on same lines (begin and end strings are equal)"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
~Pellentesque maximus faucibus lectus, in ultricies lorem volutpat in.~ Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus. ~Praesent in justo et ante faucibus eleifend in ac est. Donec orci magna, pellentesque id libero nec, faucibus porta purus.
Pellentesque luctus sollicitudin tortor sit amet accumsan. Nullam mauris felis, egestas in faucibus in, feugiat vel arcu.~
Cras rhoncus aliquam tristique.
EOF

read -r -d '' EXPECTED <<'EOF'
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
~new text here~ Sed rutrum risus et vehicula rhoncus. Nunc sed est et eros mollis vehicula. Pellentesque semper dignissim maximus. ~new text here~
Cras rhoncus aliquam tristique.
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '~' -e '~' -r 'new text here' < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#13: Block on different lines (begin and end strings are equal)"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
texte sans rien
--
texte avec un ~tag~ en plein milieu
--
~tag~ au début
--
la fin se termine par ~tag~
--
~tag~
--
la fin se termine par ~tag~
--
la fin se termine par ~tag
sur deux lignes~
--
la fin se termine par ~tag
sur deux lignes~ avec texte après
--
~tag
sur deux lignes~
--
~tag
sur deux lignes~ avec texte après
--
deux ~tag1~ et ~tag2~
--
deux ~tag1~ et ~tag sur
ligne suivante~
--
entre
~
texte à 
changer
~
EOF

read -r -d '' EXPECTED <<'EOF'
texte sans rien
--
texte avec un ~/* tag */~ en plein milieu
--
~/* tag */~ au début
--
la fin se termine par ~/* tag */~
--
~/* tag */~
--
la fin se termine par ~/* tag */~
--
la fin se termine par ~/* tag
sur deux lignes */~
--
la fin se termine par ~/* tag
sur deux lignes */~ avec texte après
--
~/* tag
sur deux lignes */~
--
~/* tag
sur deux lignes */~ avec texte après
--
deux ~/* tag1 */~ et ~/* tag2 */~
--
deux ~/* tag1 */~ et ~/* tag sur
ligne suivante */~
--
entre
~
/* texte à 
changer */
~
EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '~' -e '~' --comment java-block < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#14: Several tests with comment /* */ (begin and end strings are equal)"

rm -f /tmp/lorem_ipsum

################################################################################################################

cat > /tmp/lorem_ipsum <<'EOF'
texte sans rien
--
texte avec un ~tag~ en plein milieu
--
~tag~ au début
--
la fin se termine par ~tag~
--
~tag~
--
la fin se termine par ~tag~
--
la fin se termine par ~tag
sur deux lignes~
--
la fin se termine par ~tag
sur deux lignes~ avec texte après
--
~tag
sur deux lignes~
--
~tag
sur deux lignes~ avec texte après
--
deux ~tag1~ et ~tag2~
--
deux ~tag1~ et ~tag sur
ligne suivante~
--
entre
~
texte à 
changer
~
EOF

read -r -d '' EXPECTED <<'EOF'
texte sans rien
--
texte avec un /* tag */ en plein milieu
--
/* tag */ au début
--
la fin se termine par /* tag */
--
/* tag */
--
la fin se termine par /* tag */
--
la fin se termine par /* tag
sur deux lignes */
--
la fin se termine par /* tag
sur deux lignes */ avec texte après
--
/* tag
sur deux lignes */
--
/* tag
sur deux lignes */ avec texte après
--
deux /* tag1 */ et /* tag2 */
--
deux /* tag1 */ et /* tag sur
ligne suivante */
--
entre

/* texte à 
changer */

EOF

assert_exec_equals \
    "cd .. ; ./bin/rbt -b '~' -e '~' --comment java-block -d < /tmp/lorem_ipsum" \
    "${EXPECTED}" \
    "#15: Several tests with comment /* */ (begin and end strings are equal), begin/end strings are deleted"

rm -f /tmp/lorem_ipsum

################################################################################################################

echo "${ok}/${total} (${ko} errors)"

#rm -f /tmp/lorem_ipsum

if [[ ${ok} -ne ${total} ]]; then
    exit 1
else
    exit 0
fi
