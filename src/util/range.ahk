range(param_start:=0,param_end:=0,param_step:=1) {
	if (!this.isNumber(param_start) || !this.isNumber(param_end) || !this.isNumber(param_step)) {
		this._internal_ThrowException()
	}

	; prepare
	l_array := []
	if (param_end == 0) {
		param_end := param_start
		param_start := 0
	}
	; make step negative -1 if start is greater than end
	if (param_start > param_end) {
		; return empty array if step makes end unreachable
		if (param_step == 0) {
			return []
		}
		param_step := -1
	}
	if (param_start == 0 && param_end == 0) {
		return l_array
	}
	l_currentStep := param_start
	; where step is 0, end at the array count
	if (param_step == 0) {
		zeroStepFlag := true
	}

	; create
	if (zeroStepFlag == true) {
		loop, % param_end - 1 {
			l_array.push(l_currentStep)
			l_currentStep += param_step
		}
	} else {
		while (l_currentStep != param_end) {
			l_array.push(l_currentStep)
			l_currentStep += param_step
		}
	}
	return l_array
}


; tests
assert.test(A.range(4), [0, 1, 2, 3])

assert.test(A.range(-4), [0, -1, -2, -3])

assert.test(A.range(1, 5), [1, 2, 3, 4])

assert.test(A.range(0, 20, 5), [0, 5, 10, 15])

assert.test(A.range(0, -4, -1), [0, -1, -2, -3])

assert.test(A.range(1, 4, 0), [1, 1, 1])

assert.test(A.range(0), [])


; omit
assert.label("negative step omitted")
assert.test(A.range(-2, -6), [-2, -3, -4, -5])

assert.label("start negative and step 1")
assert.test(A.range(-6, -2), [-6, -5, -4, -3])

assert.label("for step = 0")
assert.test(A.range(1, 4, 0), [1, 1, 1])

assert.label("all parameters omitted")
assert.test(A.range(), [])

assert.label("unreachable end with 0 step")
assert.test(A.range(4, 1, 0), [])

assert.label("negative step required")
assert.test(A.range(50, 48), [50, 49])
