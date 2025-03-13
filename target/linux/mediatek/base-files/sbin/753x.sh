#!/bin/bash

RAW_OUTPUT=`switch reg r 0x781c | cut -d'=' -f3`
REG_VALUE=0x$RAW_OUTPUT
CHIP_ID=$[$REG_VALUE>>16]

function modify_100base()
{
    echo "7531 need fix 100base reg!"
    for i in {1..4}
    do
        echo "Set $i port"
        switch phy cl45 w $i 0x1e 0x1 0x01c0
        switch phy cl45 w $i 0x1e 0x7 0x03c0
        switch phy cl45 w $i 0x1e 0x4 0x209
        switch phy cl45 w $i 0x1e 0xA 0xc
    done

    for i in {1..4}
    do
        echo "Check $i port"
        switch phy cl45 r $i 0x1e 0x1
        switch phy cl45 r $i 0x1e 0x7
        switch phy cl45 r $i 0x1e 0x4
        switch phy cl45 r $i 0x1e 0xA
    done
}

function modify_collision()
{
    echo "7531 need modify collision reg!"
    local val=0x`switch reg r 30e0 | cut -d'=' -f3`
    local new_val=$[$val&0xE1FF]
    local hex=`printf "%x" $new_val`
    switch reg w 30e0 $hex
}

if [[ "$CHIP_ID" -eq 0x7531 ]];then
    modify_100base
    modify_collision
    resize
fi
