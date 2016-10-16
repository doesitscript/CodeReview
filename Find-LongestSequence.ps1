$myString="yzadgjqbfghijkabcdefghz"
$newSequence = ""
for($i = 0;$i -lt $myString.Length; $i++) {
    if ($myString[$i] -ge $newSequence[$newSequence.Length -1]) {
        $newSequence += $myString[$i]
        if ($newSequence.Length -gt $longestSequence.Length) {
            $longestSequence = $newSequence
        } #end if
    } else {
        $newSequence = $myString[$i]
    }
}
$longestSequence