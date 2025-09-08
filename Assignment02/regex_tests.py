import re

# 1) C++ identifiers
pattern_id = r'^[A-Za-z_][A-Za-z0-9_]*$'
for t in ["var1", "_thing", "9bad"]:
    print("ID:", t, "->", bool(re.match(pattern_id, t)))

# 2) U.S. phone numbers
pattern_phone = r'^(\(\d{3}\)\s|\d{3}-)\d{3}-\d{4}$'
for t in ["(256) 555-1212", "256-555-1212", "5551212"]:
    print("Phone:", t, "->", bool(re.match(pattern_phone, t)))

# 3) Floating point numbers with optional sign/decimal
pattern_float = r'^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$'
for t in ["3.14", "-0.5", "+42", ".", "abc"]:
    print("Float:", t, "->", bool(re.match(pattern_float, t)))

# 4) Binary palindromes of length 3 or 4
pattern_binpal = r'^(000|010|101|111|0110|1001|1111|0000)$'
for t in ["101", "0110", "111", "0101"]:
    print("BinPal:", t, "->", bool(re.match(pattern_binpal, t)))

