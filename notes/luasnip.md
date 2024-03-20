# LuaSnip

LuaSnip is a snippet engine written in lua.

At a high level a snippet associates a trigger string to a tree of snippet nodes. When the string to the left of the cursor matches the trigger string of a particular snippet (you can choose when you define your snippet whether you want that match to be exact or based on a regex, etc.) you can call the `luasnip.expand` function which will replace the trigger text by the content of the snippet.

The rendered text of a snippet depends on its definition which relies on several primitives (nodes). The main ones are:
- `textNodes`: get expanded to static text
- `insertNode`: get expanded to a placeholder where you can input text
- `functionNode`: get expanded by calling a function to which you can pass other elements of the snippet (useful if you want to repeat some content)
- `choiceNode`: allows to cycle between several options (useful if you want to include default values)
- `dynamicNode`: get expanded to whatever base on the content of the snippet so far

Once a snippet is defined, it needs to be added for a filetype specifically or using the filetype `all` if it should be used in any buffer. If not added, the snippet is not added.

Nodes come with an index which allows to easily jump from node to node for easier editing. You should see snippets as trees, you can decide to link snippets together (meaning if you create a new snippet, it won't be created as a standalone root, but as a child of the last nodes of the previous snippet) with the `link_roots` configuration parameter. By default LuaSnip forgets about previously inserted snippets, you can decide to change that with the `keep_roots` configuration parameter (you need to set it to true if you want to use `link_roots`. Also by default cycling through nodes happens only through brothers and does not go into children, if you want to explore all the nodes in a DFS way you need to set `link_children`.

LuaSnip is also capable of parsing other snippet formats, such as LSP-style snippets or Snipmate-style snippets, and generating the proper snippet node structure.
