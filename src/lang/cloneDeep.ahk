cloneDeep(param_array,Objs := 0) {
    if (!Objs) {
        Objs := {}
    }
    Obj := param_array.Clone()
    Objs[&param_array] := Obj ; Save this new array
    For Key, Val in Obj
    {
        if (IsObject(Val)) ; If it is a subarray
            Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
            ? Objs[&Val] ; Then point it to the new array
            : this.clone(Val,Objs) ; Otherwise, clone this sub-array
    }
    return Obj
}

; tests
object := [{ "a": [[1,2,3]] }, { "b": 2 }]
deepclone := A.cloneDeep(object)
object.a := 2
assert.test(deepclone,[{ "a": [[1,2,3]] }, { "b": 2 }])