class_name ParseUtils
## Provides utility functions for parsing from/to raw data.
# CAUTION
# The built-in JSON parser converts all integers into floats.
# So any number loaded from JSON data will be a float, not an int.
# One important implication of this is that extremely large integer numbers
# will lose precision when they are converted to floats.
# For example, if you try to save the number 3162759323876435874 to JSON,
# the parser will convert it to a float and it will become 3162759323876435968.
# It is up to you to prevent precision errors
# (i.e. don't save extremely large numbers directly as integers).
# One way to do it is by saving the number as a [String].
# This class will consider it a valid number and convert it to an integer.


## Returns true if given dictionary has given key and its value is a number.
static func dictionary_has_number(dictionary: Dictionary, key: String) -> bool:
	return dictionary.has(key) and is_number(dictionary[key])


## Returns the value associated with given key in given dictionary,
## parsed as an int. This may crash the game! Make sure that the dictionary
## has the key and that it's indeed a number, using dictionary_has_number.
static func dictionary_int(dictionary: Dictionary, key: String) -> int:
	return number_as_int(dictionary[key])


## Returns true if given dictionary has given key and its value is a boolean.
static func dictionary_has_bool(dictionary: Dictionary, key: String) -> bool:
	return dictionary.has(key) and dictionary[key] is bool


## Returns true if given dictionary has given key
## and its value is a dictionary.
static func dictionary_has_dictionary(
		dictionary: Dictionary, key: String
) -> bool:
	return dictionary.has(key) and dictionary[key] is Dictionary


## Returns true if given variant is either an int or a float.
static func is_number(variant: Variant) -> bool:
	match typeof(variant):
		TYPE_INT, TYPE_FLOAT:
			return true
		TYPE_STRING:
			var string := variant as String
			return string.is_valid_int() or string.is_valid_float()
	
	return false


## Returns the given number parsed as an int.
## Consider using is_number first to make sure it's a number.
static func number_as_int(variant: Variant) -> int:
	match typeof(variant):
		TYPE_INT:
			return variant
		TYPE_FLOAT:
			return roundi(variant)
		TYPE_STRING:
			var string := variant as String
			if string.is_valid_int():
				return string.to_int()
			elif string.is_valid_float():
				return number_as_int(string.to_float())
	
	push_error("That's not a valid number!")
	return 0
