--dofile("test1.lua")

test_callfunc = {}

function test_callfunc.func1(arg0)
	print(string.format("self:%s, arg0:%s", tostring(self), tostring(arg0)))
end

function test_callfunc:func2(arg0)
	print(string.format("self:%s, arg0:%s", tostring(self), tostring(arg0)))
end

print("call test_callfunc.func1(\"yes\")")
test_callfunc.func1("yes")
print("\n")
print("\n")

print("call test_callfunc:func1(\"yes\")")
test_callfunc:func1("yes")
print("\n")
print("\n")

print("call test_callfunc.func2(\"yes\")")
test_callfunc.func2("yes")
print("\n")
print("\n")


print("call test_callfunc:func2(\"yes\")")
test_callfunc:func2("yes")
print("\n")
print("\n")
