{
  declare -pA addCommand=([action]="add" [identifier]="dashboard" [x]="0" [y]="0" [path]="$1")
  sleep 100
} | ueberzug layer --parser bash
