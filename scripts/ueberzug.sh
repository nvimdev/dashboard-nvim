#!/bin/bash
function draw_image() {
	{
	    declare -pA cmd=([action]="add" [identifier]="preview" [x]="$2" [y]="$3" [path]="$1" [width]="$4" [height]="$5")
	    sleep 100
	} | ueberzug layer --parser bash
}

draw_image "$@"
