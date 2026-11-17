local M = {}

local function parse_request_line(line)
  local method, url, version = line:match("^(%S+)%s+(%S+)%s*(.*)")
  if not method or not url then
    return nil, "Invalid HTTP request line format"
  end
  
  if method:upper() ~= "GET" and method:upper() ~= "POST" and method:upper() ~= "PUT" and method:upper() ~= "DELETE" and method:upper() ~= "PATCH" then
    return nil, "Unsupported HTTP method: " .. method
  end
  
  return {
    method = method:upper(),
    url = url,
    version = version ~= "" and version or "HTTP/1.1"
  }, nil
end

local function make_http_request(request_info)
  local cmd = string.format("curl -i -X %s '%s' 2>/dev/null", request_info.method, request_info.url)
  
  local handle = io.popen(cmd)
  if not handle then
    return nil, "Failed to execute curl command"
  end
  
  local result = handle:read("*a")
  local success, exit_type, exit_code = handle:close()
  
  if not success then
    return nil, "Request failed with exit code: " .. tostring(exit_code)
  end
  
  return result, nil
end

local function show_response_in_window(response)
  -- Remove carriage returns (^M characters) from the response
  local cleaned_response = response:gsub('\r', '')
  local lines = vim.split(cleaned_response, '\n')
  
  -- Create a new buffer for the response
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  
  -- Set initial filetype to http for headers
  vim.api.nvim_buf_set_option(buf, 'filetype', 'http')
  
  -- Apply custom syntax highlighting after window is created
  vim.defer_fn(function()
    vim.api.nvim_buf_call(buf, function()
      -- Define custom highlight groups for HTTP headers
      vim.cmd('highlight HTTPHeaderName guifg=#569CD6 ctermfg=75')  -- Blue for header names
      vim.cmd('highlight HTTPHeaderValue guifg=#D4D4D4 ctermfg=188') -- Light gray for header values
      vim.cmd('highlight HTTPStatus guifg=#4EC9B0 ctermfg=79')       -- Cyan for status line
      
      -- Clear existing syntax and define custom patterns
      vim.cmd('syntax clear')
      
      -- Status line highlighting (first line)
      vim.cmd('syntax match HTTPStatus /^HTTP\\/.*/')
      
      -- Header name/value pairs
      vim.cmd('syntax match HTTPHeaderName /^[A-Za-z-]\\+:/ contained')
      vim.cmd('syntax match HTTPHeaderValue /:.*$/ contained')
      vim.cmd('syntax match HTTPHeader /^[A-Za-z-]\\+:.*$/ contains=HTTPHeaderName,HTTPHeaderValue')
      
      -- Check if response contains JSON and apply additional highlighting
      local is_json = cleaned_response:match("[Cc]ontent%-[Tt]ype:.*application/json")
      if is_json then
        -- Find where the JSON body starts (after headers)
        local json_start_line = nil
        for i, line in ipairs(lines) do
          if line:match("^%s*$") then
            json_start_line = i + 1
            break
          end
        end
        
        if json_start_line then
          -- Apply JSON syntax highlighting to the body
          vim.cmd('syntax include @JSON syntax/json.vim')
          -- Use a more inclusive regex that covers the entire JSON body including the last line
          vim.cmd(string.format('syntax region HTTPResponseJSON start=/\\%%%dl/ end=/\\%%%dl$/ contains=@JSON', 
            json_start_line, #lines))
        end
      end
    end)
  end, 50)
  
  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create floating window
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' HTTP Response ',
    title_pos = 'center'
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Set window-local keymaps for easy dismissal
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set('n', 'q', '<cmd>close<cr>', opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
end

function M.execute_http_request()
  local current_line = vim.fn.getline('.')
  
  local request_info, parse_err = parse_request_line(current_line)
  if not request_info then
    vim.api.nvim_echo({{"Error parsing request: " .. parse_err, "ErrorMsg"}}, false, {})
    return
  end
  
  local response, request_err = make_http_request(request_info)
  if not response then
    vim.api.nvim_echo({{"Request failed: " .. request_err, "ErrorMsg"}}, false, {})
    return
  end
  
  show_response_in_window(response)
end

function M.setup()
  vim.api.nvim_create_user_command("DoRequest", M.execute_http_request, {
    desc = "Execute HTTP request from current line"
  })
  
  vim.keymap.set("n", "<leader>hr", M.execute_http_request, {
    desc = "Execute HTTP request from current line",
    noremap = true,
    silent = true
  })
end

return M