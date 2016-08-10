function tessellate(vertices, new_vertices)
   MIX_FACTOR = .5
   new_vertices[#vertices*2] = 0
   for i=1,#vertices,2 do
      local newindex = 2*i
      -- indexing brackets:
      -- [1, *2*, 3, 4], [5, *6*, 7, 8]
      -- bracket center: 2*i
      -- bracket start: 2*1 - 1
      new_vertices[newindex - 1] = vertices[i];
      new_vertices[newindex] = vertices[i+1]
      if not (i+1 == #vertices) then
    -- x coordinate
    new_vertices[newindex + 1] = (vertices[i] + vertices[i+2])/2
    -- y coordinate
    new_vertices[newindex + 2] = (vertices[i+1] + vertices[i+3])/2
      else
    -- x coordinate
    new_vertices[newindex + 1] = (vertices[i] + vertices[1])/2
    -- y coordinate
    new_vertices[newindex + 2] = (vertices[i+1] + vertices[2])/2
      end
   end

   for i = 1,#new_vertices,4 do
      if i == 1 then
       -- x coordinate
       new_vertices[1] = MIX_FACTOR*(new_vertices[#new_vertices - 1] + new_vertices[3])/2 + (1 - MIX_FACTOR)*new_vertices[1]
       -- y coordinate
       new_vertices[2] = MIX_FACTOR*(new_vertices[#new_vertices - 0] + new_vertices[4])/2 + (1 - MIX_FACTOR)*new_vertices[2]
      else
       -- x coordinate
       new_vertices[i] = MIX_FACTOR*(new_vertices[i - 2] + new_vertices[i + 2])/2 + (1 - MIX_FACTOR)*new_vertices[i]
       -- y coordinate
       new_vertices[i + 1] = MIX_FACTOR*(new_vertices[i - 1] + new_vertices[i + 3])/2 + (1 - MIX_FACTOR)*new_vertices[i + 1]
      end
   end
end




return function(vert,rate,times) --vert={x,y,x1,y1...} rate
  rate=rate or 2
  times=times or 4
	local result={}
	local rated={}
	for i=1,#vert,rate*2 do
		table.insert(rated,vert[i])
		table.insert(rated,vert[i+1])
	end


   for i=1,times do
		result[i]={}
	end
	tessellate(rated, result[1])
	for i=1,times - 1 do
		tessellate(result[i], result[i+1]);
	end

   table.insert(result[times],result[times][1])
   table.insert(result[times],result[times][2])
   
	return result[times]
end