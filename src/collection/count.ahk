count(param_collection,param_predicate,param_fromIndex:=1) {

	; prepare
	shorthand := this._internal_differenciateShorthand(param_predicate, param_collection)
	if (shorthand != false) {
		boundFunc := this._internal_createShorthandfn(param_predicate, param_collection)
	}

	; create
	l_count := 0
	if (this.isString(param_collection)) {
		; cut fromindex length off from start of string if specified fromIndex > 1
		if (param_fromIndex > 1) {
			param_collection := subStr(param_collection, param_fromIndex, strLen(param_collection))
		}
		param_collection := this.split(param_collection, param_predicate)
		return param_collection.count() - 1
	}
	for key, value in param_collection {
		if (key < param_fromIndex) {
			continue
		}
		if (shorthand != false) {
			if (boundFunc.call(value, key, param_collection) == true) {
				l_count++
				continue
			}
		}
		if (this.isEqual(value, param_predicate)) {
			l_count++
		}
	}
	return l_count
}


; tests
assert.test(A.count([1, 2, 3], 2), 1)
assert.test(A.count("pebbles", "b"), 2)
assert.test(A.count(["fred", "barney", "pebbles"], "barney"), 1)

users := [ {"user": "fred", "age": 40, "active": true}
		, {"user": "barney", "age": 36, "active": false}
		, {"user": "pebbles", "age": 1, "active": false} ]

; The `A.matches` iteratee shorthand.
assert.test(A.count(users, {"age": 1, "active": false}), 1)

; The `A.matchesProperty` iteratee shorthand.
assert.test(A.count(users, ["active", false]), 2)

; The `A.property` iteratee shorthand.
assert.test(A.count(users, "active"), 1)


; omit
assert.label("double characters")
assert.test(A.count("pebbles", "bb"), 1)
assert.label("double characters2")
assert.test(A.count("....", ".."), 2)
assert.test(A.count("   ", "test"), 0)
assert.test(A.count(1221221221, 22), 3)
