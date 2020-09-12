--- system

local N = 3
-- local M = 2 -- actually unused
local L = 1000

local T = {
  {  60, 20, 20 },
  {   0, 70, 30 },
  {  70, 10, 20 },
}

local O = {
  { 5, 95 },
  { 55, 45 },
  { 90, 10 },
}

--- sanity checks

local sum = function(t)
  local s = 0
  for i=1,#t do s = s + t[i] end
  return s
end

for i=1,N do
  assert(sum(T[i]) == 100)
  assert(sum(O[i]) == 100)
end

--- simulation
local proba_pick = function(v)
  local p,s = math.random(1,100),0
  for i=1,#v do
    s = s + v[i]
    if p <= s then
      return i
    end
  end
  assert(false)
end

local S,V = {},{}

local transition = function(t)
  assert(S[t-1] and not S[t])
  S[t] = proba_pick(T[S[t-1]])
end

local observe = function(t)
  assert(S[t] and not V[t])
  V[t] = proba_pick(O[S[t]])
end

S[1] = math.random(1,N)
observe(1)

for t=2,L do
  transition(t)
  observe(t)
end

--- viterbi

local treillis = {{}}

local prb = function(x)
  return math.log(x/100)
end

local viterbi_node = function(t,i)
  local prev = assert(treillis[t-1])
  local idx,proba = 0,-math.huge
  local p
  for j=1,N do
    p = prev[j].proba + prb(T[j][i]) + prb(1/N*O[i][V[t]])
    if p > proba then proba,idx = p,j end
  end
  return {
    state = i,
    proba = proba,
    prev = prev[idx],
  }
end

local viterbi_step = function(t)
  assert(not treillis[t])
  treillis[t] = {}
  for i=1,N do
    treillis[t][i] = viterbi_node(t,i)
  end
end

-- initialize the treillis
for i=1,N do
  treillis[1][i] = {
    state = i,
    proba = prb(1/N*O[i][V[1]])
  }
end

-- run the algorithm
for t=2,L do
  viterbi_step(t)
end

--- backtracking

local getpath = function(node)
  local r = {}
  repeat
    table.insert(r,1,node.state)
    node = node.prev
  until (not node)
  return r
end

local best_node = function(nodes)
  local r = {proba = -math.huge}
  for i=1,#nodes do
    if nodes[i].proba > r.proba then
      r = nodes[i]
    end
  end
  return r
end

local bestpath = getpath(best_node(treillis[L]))

local ok = 0
for i=1,L do
  if S[i] == bestpath[i] then
    ok = ok + 1
  end
end

print(100*ok/L)
