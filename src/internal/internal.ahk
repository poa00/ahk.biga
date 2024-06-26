; /--\--/--\--/--\--/--\--/--\
; Internal functions
; \--/--\--/--\--/--\--/--\--/



_internal_MD5(param_string,case:=0) {
	if (isObject(param_string)) {
		param_string := this._internal_stringify(param_string)
	}
	digestLength := 16
	hModule := dllCall("loadlibrary", "str", "advapi32.dll", "ptr")
	, VarSetCapacity(MD5_CTX, 104, 0), dllCall("advapi32\MD5Init", "ptr", &MD5_CTX)
	, dllCall("advapi32\MD5Update", "ptr", &MD5_CTX, "AStr", param_string, "UInt", strLen(param_string))
	, dllCall("advapi32\MD5Final", "ptr", &MD5_CTX)
	loop % digestLength {
		output .= format("{:02" (case ? "X" : "x") "}", numGet(MD5_CTX, 87 + A_Index, "UChar"))
	}
	dllCall("freelibrary", "ptr", hModule)
	return output
}



_internal_JSRegEx(param_string) {
	if (!this.isString(param_string) && !this.isAlnum(param_string)) {
		this._internal_ThrowException()
	}
	if (this.startsWith(param_string, "/") && this.endsWith(param_string, "/")) {
		return subStr(param_string, 2, strLen(param_string) - 2)
	}
	return false
}


_internal_detectShorthand(param_shorthand,param_objects:="") {
	if (this._internal_detectOwnMethods(param_shorthand)) {
		return "_classMethod"
	}
	if (isObject(param_shorthand) && !this.isFunction(param_shorthand)) {
		if (param_shorthand.maxIndex() != param_shorthand.count()) {
			return ".matches"
		}
		return ".matchesProperty"
	}
	if (this.isStringLike(param_shorthand) && isObject(param_objects)) {
		for key, value in param_objects {
			if (value.hasKey(param_shorthand)) {
				return ".property"
			}
		}
	}
	if (param_shorthand == "__identity") {
		return param_shorthand
	}
	return false
}


_internal_createShorthandfn(param_shorthand,param_objects:="") {
	shorthand := this._internal_detectShorthand(param_shorthand, param_objects)
	if (shorthand == "_classMethod") {
		return param_shorthand.bind(this)
	}
	if (shorthand == ".matches") {
		return this.matches(param_shorthand)
	}
	if (shorthand == ".matchesProperty") {
		return this.matchesProperty(param_shorthand[1], param_shorthand[2])
	}
	if (shorthand == ".property") {
		return this.property(param_shorthand)
	}
	if (param_shorthand == "__identity") {
		boundFunc := objBindMethod(this, "identity")
		return boundFunc
	}
}


_internal_detectOwnMethods(param_iteratee) {
	;if starts with "biga."
	if (this.startsWith(param_iteratee.name, this.__Class ".") && isObject(param_iteratee)) {
		return true
	}
	return false
}


_internal_iterateeDetails(param_iteratee) {
	returnObj := {}
	returnObj.methodName := strSplit(param_iteratee.name, ".").2
	returnObj.guarded := this.includes(this._guardedMethods, returnObj.methodName)
	; call with preceeding 1
	if (this.includes(this._guardedCallWithOne, returnObj.methodName)) {
		returnObj.iteratee := param_iteratee.bind(this, 1)
	} else if (this.includes(this._guardedMethods, returnObj.methodName)) {
		returnObj.iteratee := param_iteratee.bind(this)
	}
	return returnObj
}


_internal_ThrowException() {
	if (this.throwExceptions == true) {
		throw Exception("Type Error", -2)
	}
}

_internal_inStr(param_haystack,param_needle,param_fromIndex:=1,param_occurance:=1) {
	; used inplace of inStr to follow A_StringCaseSense
	if (A_StringCaseSense == "On") {
		StringCaseSense := 1
	} else {
		StringCaseSense := 0
	}
	if (position := inStr(param_collection, param_value, StringCaseSense, param_fromIndex, param_occurance)) {
		return position
	} else {
		return false
	}
}

_internal_stringify(param_value) {
	if (!isObject(param_value)) {
		return """" param_value """"
	}
	for key, value in param_value {
		if key is not number
		{
			output .= """" key """:"
		} else {
			output .= key ":"
		}
		if (isObject(value)) {
			output .= "[" this._internal_stringify(value) "]"
		} else if value is not number
		{
			output .= """" value """"
		} else {
			output .= value
		}
		output .= ", "
	}
	return subStr(output, 1, -2)
}

isFalsey(param) {
	if (isObject(param)) {
		return false
	}
	if (param == "" || param == 0) {
		return true
	}
	return false
}

isStringLike(param) {
	if (this.isString(param) || this.isAlnum(param)) {
		return true
	}
	return false
}


; tests
assert.label("_internal_JSRegEx")
assert.test(A._internal_JSRegEx("/RegEx(capture)/"),"RegEx(capture)")

assert.label("md5")
assert.notEqual(A._internal_MD5({"a": [1,2,[3]]}), A._internal_MD5({"a": [1,2,[99]]}))

assert.label("isFalsey")
assert.true(A.isFalsey(0))
assert.true(A.isFalsey(""))
assert.false(A.isFalsey([]))
assert.false(A.isFalsey({}))


; omit
assert.group("internal_stringify")
assert.test(A._internal_stringify([1, 2, 3]), "1:1, 2:2, 3:3")

assert.test(A._internal_stringify([1, 2, [3]]), "1:1, 2:2, 3:[1:3]", "deep object")

assert.test(A._internal_stringify("hello world"), """hello world""")

assert.group("internal_MD5")
; assert.label("boolean value")
; assert.test(A._internal_MD5(true), [true])
; assert.test(A._internal_MD5(false), [false])

; assert.label("an undefined value")
; assert.test(A._internal_MD5(non_existant_var), [non_existant_var])
; assert.test(A._internal_MD5(""), [""])

; assert.label("number that is not 1")
; assert.test(A._internal_MD5(0), [0])
; assert.test(A._internal_MD5(2), [2])

; assert.label("string input")
; assert.test(A._internal_MD5("def"), ["def"])

; assert.label("complex object")
; assert.test(A._internal_MD5({"a": 1, "b": 2}), {"a": 1, "b": 2})

; assert.label("an array of multiple elements")
; assert.test(A._internal_MD5([1, 2, 3, 4]), [1, 2, 3, 4])

; assert.label("an empty object")
; assert.test(A._internal_MD5({}), [{}])

; assert.label("an empty array")
; assert.test(A._internal_MD5([]), [[]])

; assert.label("string containing special characters")
; assert.test(A._internal_MD5("@#$%^&*()"), ["@#$%^&*()"])

; assert.label("negative number")
; assert.test(A._internal_MD5(-1), [-1])
