sortedIndex(param_array,param_value) {
    if (param_value < param_array[1]) {
        return 1
    }
    loop, % param_array.Count() {
        if (param_array[A_Index] < param_value && param_value < param_array[A_Index+1]) {
            return % A_Index + 1
        }
    }
    return % param_array.Count() + 1
}


; tests

assert.test(A.sortedIndex([30, 50], 40),2)
assert.test(A.sortedIndex([30, 50], 20),"1")
