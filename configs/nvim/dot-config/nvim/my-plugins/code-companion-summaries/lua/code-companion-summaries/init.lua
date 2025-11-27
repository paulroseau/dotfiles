-- TODO:
-- create a dedicated strategy to send the summaries request to
-- next: check if we could use an agent to do that (maybe overkill)
local group = vim.api.nvim_create_augroup("CodeCompanionSummarizeFirstQuestion", { clear = true })

local function first_question_content(bufnr)
  local start_line = 3
  local last_line = vim.api.nvim_buf_line_count(bufnr)
  if last_line < start_line then return "" end

  -- Find the next "## Me"
  local end_line = last_line
  local scanned_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, last_line, false)
  for i, line in ipairs(scanned_lines) do
    if line:match("^##%s*Me") then
      end_line = start_line + i - 2 -- line before the heading
      break
    end
  end
  if end_line < start_line then return "" end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false) -- end is exclusive
  return table.concat(lines, "\n")
end

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "ChatSubmitted", -- change if CodeCompanion uses a different pattern name
  desc = "Summarize the first question of the chat",
  callback = function(args)
    local bufnr = (args.buf and args.buf > 0) and args.buf or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_loaded(bufnr) then return end

    local first_question_content = first_question_content(bufnr)

    -- Make it accessible after the callback
    vim.g.first_question = first_question_content        -- global variable
    vim.b[bufnr].first_question = first_question_content -- buffer-local variable
  end,
})

local function openai_chat_async(text, opts, cb)
  opts = opts or {}
  local api_key = opts.api_key or vim.env.OPENAI_API_KEY
  if not api_key or api_key == "" then
    return cb(nil, "OPENAI_API_KEY is not set")
  end
  local model = opts.model or "gpt-4o-mini"
  local url = opts.url or "https://api.openai.com/v1/chat/completions"

  local prompt = "Summarize the given text in 50 characters or fewer. " ..
      "Return only the summary, no quotes or extra text."

  local body_tbl = {
    model = model,
    temperature = 0.2,
    max_tokens = 64,
    messages = {
      { role = "system", content = prompt },
      { role = "user",   content = text },
    },
  }
  local body = vim.json.encode(body_tbl)

  local args = {
    "curl", "-sS",
    "-H", "Authorization: Bearer " .. api_key,
    "-H", "Content-Type: application/json",
    "-X", "POST", url,
    "-d", body,
  }

  vim.system(args, { text = true }, function(res)
    if res.code ~= 0 then
      return cb(nil, string.format("curl exit code %d: %s", res.code, res.stderr or ""))
    end
    local ok, decoded = pcall(vim.json.decode, res.stdout)
    if not ok then
      return cb(nil, "Failed to decode OpenAI response")
    end
    local content = decoded
        and decoded.choices
        and decoded.choices[1]
        and decoded.choices[1].message
        and decoded.choices[1].message.content

    if not content or content == "" then
      return cb(nil, "Empty response from OpenAI")
    end
    -- Ensure hard limit of 50 chars (defensive)
    content = truncate_utf8(vim.trim(content), 50)
    cb(content, nil)
  end)
end

-- other option using CodeCompanion:
--
--
-- local function openai_chat_async(text, opts, cb)
--   opts = opts or {}
--
--   -- 1) CodeCompanion adapter path (adjusted to common adapter shapes)
--   local ok_adapters, adapters = pcall(require, "codecompanion.adapters")
--   if ok_adapters and adapters then
--     local openai = (adapters.get and adapters.get("openai")) or adapters.openai
--     if openai then
--       local prompt = "Summarize the given text in 50 characters or fewer. Return only the summary."
--       local payload = {
--         messages = {
--           { role = "system", content = prompt },
--           { role = "user",   content = text },
--         },
--         temperature = 0.2,
--         max_tokens = 64,
--         stream = false,
--       }
--
--       -- Try common call shapes used by adapters
--       local function use_result(err, res)
--         if err then return cb(nil, err) end
--         local content = nil
--         if type(res) == "table" then
--           content = res.content
--             or (res.choices and res.choices[1]
--               and res.choices[1].message
--               and res.choices[1].message.content)
--         elseif type(res) == "string" then
--           content = res
--         end
--         if not content or content == "" then
--           return cb(nil, "Empty response from CodeCompanion/OpenAI adapter")
--         end
--         content = truncate_utf8(vim.trim(content), 50)
--         return cb(content, nil)
--       end
--
--       if type(openai.chat) == "function" then
--         return openai.chat(payload, use_result)
--       elseif type(openai.request) == "function" then
--         return openai.request("chat", payload, use_result)
--       elseif type(openai.complete) == "function" then
--         return openai.complete(payload, use_result)
--       end
--       -- If adapter is present but has no callable method, fall through to curl
--     end
--   end
