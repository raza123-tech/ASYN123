!/bin/bash

design="design.v"
test="tb.sv"
logs="log"
out="a.out"

mkdir -p $logs


TEST=("reset" "afull" "aempty" "write" "read" "overflow" "underflow" "wrap" "sw")

iverilog -g2012 -o $out $design $test

PASS=0
FAIL=0

for t in "${TEST[@]}";
do
echo "Running the test $t"
    vvp $out +char=$t | tee $logs/$t.log
    grep -q "success" $logs/$t.log
   
    if [ $? -eq 0 ]; then
        ((PASS++))  
    else
        ((FAIL++))
    fi
done

echo "THE NUMBER OF PASS: $PASS"
echo "THE NUMBER OF FAIL: $FAIL"

if [ $FAIL -eq 0 ]; then
    exit 0
else
    exit 1
fi
