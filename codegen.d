module codegen;

import std.range;


class Trie(K, V) if (isInputRange!K): TrieNode!(K, V)
{
	/**
	 * Adds the given value to the trie with the given key
	 */
	void add(K key, V value) pure
	{
		TrieNode!(K,V) current = this;
		foreach(keyPart; key)
		{
			if ((keyPart in current.children) is null)
			{
				auto node = new TrieNode!(K, V);
				current.children[keyPart] = node;
				current = node;
			}
			else
				current = current.children[keyPart];
		}
		current.value = value;
	}
}

class TrieNode(K, V) if (isInputRange!K)
{
	V value;
	TrieNode!(K,V)[ElementType!K] children;
}

string printCaseStatements(K, V)(TrieNode!(K,V) node, string indentString)
{
	string caseStatement = "";
	foreach(dchar k, TrieNode!(K,V) v; node.children)
	{
		caseStatement ~= indentString;
		caseStatement ~= "case '";
		caseStatement ~= k;
		caseStatement ~= "':\n";
		caseStatement ~= indentString;
		caseStatement ~= "\tcurrentToken.value ~= '";
		caseStatement ~= k;
		caseStatement ~= "';\n";
		caseStatement ~= indentString;
		caseStatement ~= "\tcurrentToken.lineNumber = lineNumber;";
		caseStatement ~= indentString;
		caseStatement ~= "\t++endIndex;\n";
		if (v.children.length > 0)
		{
			caseStatement ~= indentString;
			caseStatement ~= "\tif (endIndex >= inputString.length)\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t{\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t\tcurrentToken.type = " ~ node.children[k].value;
			caseStatement ~= ";\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t\tbreak;\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t}\n";
			caseStatement ~= indentString;
			caseStatement ~= "\tswitch (inputString[endIndex])\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t{\n";
			caseStatement ~= printCaseStatements(v, indentString ~ "\t");
			caseStatement ~= indentString;
			caseStatement ~= "\tdefault:\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t\tcurrentToken.type = ";
			caseStatement ~= v.value;
			caseStatement ~= ";\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t\tbreak;\n";
			caseStatement ~= indentString;
			caseStatement ~= "\t}\n";
			caseStatement ~= indentString;
			caseStatement ~= "\tbreak;\n";
		}
		else
		{
			caseStatement ~= indentString;
			caseStatement ~= "\tcurrentToken.type = ";
			caseStatement ~= v.value;
			caseStatement ~= ";\n";
			caseStatement ~= indentString;
			caseStatement ~= "\tbreak;\n";
		}
	}
	return caseStatement;
}

string generateCaseTrie(string[] args ...)
{
	auto t = new Trie!(string, string);
	for(int i = 0; i < args.length; i+=2)
	{
		t.add(args[i], args[i+1]);
	}
	return printCaseStatements(t, "");
}