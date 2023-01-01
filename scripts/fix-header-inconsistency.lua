--[[ 
  [For Sphinx reStructuredText] Fix inconsistency of headers

  # Synopsis

  ## Before

  ```
  # first level
  ## second level
  ## second level
  #### should be third level
  ## second level
  ### third level
  #### should be fourth level
  ```

  ## after (empty lines are removed)

  ```
  # first level
  ## second level
  ## second level
  ### should be third level
  ## second level
  ### third level
  #### should be fourth level
  ```

 ]]

--[[ 
  MIT License

  Copyright (c) 2022 sky-y

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

-- for debug using [wlupton/pandoc-lua-logging](https://github.com/wlupton/pandoc-lua-logging)
-- local logging = require 'logging'

local prev_level = 1
local current_level = 1

function Header(el)
  if el.level > prev_level then
    current_level = current_level + 1
  elseif el.level < current_level then
    current_level = el.level
  end

  prev_level = el.level
  el.level = current_level

  return el
end
