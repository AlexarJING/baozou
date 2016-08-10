local soft=Class("softbody")
local smooth=require("smooth")

function soft:initialize(x,y,verts,pic,step)
	local l,t,r,b --上下左右
	local pX={}
	local pY={}
	self.offX=x
	self.offY=y
	self.step=step or 15
	self.pic=pic

	verts=math.polygonTrans(x,y,0,1,verts)
	local sumX=0
	local sumY=0
	for i=1,#verts,2 do
		l=l or verts[i]
		r=r or verts[i]
		t=t or verts[i+1]
		b=b or verts[i+1]
		l= verts[i]<l and  verts[i] or l
		r= verts[i]>r and  verts[i] or r
		t= verts[i+1]<t and  verts[i+1] or t
		b= verts[i+1]>b and  verts[i+1] or b
		sumX=sumX+verts[i]
		sumY=sumY+verts[i+1]
		table.insert(pX, verts[i])
		table.insert(pY, verts[i+1])
	end
	self.cx=sumX*2/#verts
	self.cy=sumY*2/#verts
	self.l,self.t,self.r,self.b=l,t,r,b
	self.center={}
	self.center.body = love.physics.newBody(world, self.cx, self.cy, "dynamic")
	self.center.body:setAngularDamping(50)
	self.center.shape = love.physics.newCircleShape( 0, 0, 10)
	self.center.fixture = love.physics.newFixture(self.center.body, self.center.shape, 100)
	self.center.fixture:setGroupIndex(-1)
	local particles={}
	local joint={}
	local bodies={}
	local connects={}
	local shapes={}
	local fixtures={}
	self.particles=particles
	for i=l+1,r-1,self.step do
		particles[i]={}
		for j=t+1,b-1,self.step do
			particles[i][j]={}
		end
	end

	for k1,v in pairs(particles) do
		for k2,v in pairs(v) do
			if math.pointTest_xy(k1,k2,pX,pY) then
				v.posX=k1
				v.posY=k2
				v.body = love.physics.newBody(world, k1, k2, "dynamic")
				v.body:setAngularDamping(50);
				v.shape = love.physics.newCircleShape(0, 0, self.step/2)
				v.fixture = love.physics.newFixture(v.body, v.shape, 1)
				v.fixture:setFriction(5);
				v.fixture:setRestitution(0.5);
				v.fixture:setGroupIndex(-1)
				v.connects={}
			else
				particles[k1][k2]=nil
			end
		end
	end

	for k1,v in pairs(particles) do
		for k2,v in pairs(v) do
			self:connectAround(k1,k2)
		end
	end

	self:getSurround()
	self:getMeshVert()
end

function soft:getMeshVert()
	local e={}
	for i,v in ipairs(self.edge) do
		table.insert(e, v.body:getX())
		table.insert(e, v.body:getY())
	end
	e=math.polygonTrans(-self.offX,-self.offY,0,1,e)
	self.vertForMesh=smooth(e)
end


function soft:getSurround()
	self.edge={}
	for k1,v in pairs(self.particles) do
		for k2,v in pairs(v) do
			if #v.connects<=6 then
				v.edge=true
				table.insert(self.edge,v)
				local joint = love.physics.newDistanceJoint(v.body, self.center.body, 
				v.body:getX(),v.body:getY(), v.body:getX(),v.body:getY(), false)
				joint:setDampingRatio(1)
				joint:setFrequency(3)
			end
		end
	end
	self:edgeSort()
end

function soft:edgeSort()
	local rot={}
	for i,v in ipairs(self.edge) do
		rot[i]= {i,math.getRot(self.cx,self.cy,v.posX,v.posY)} --i 为位置， 后面为角度
	end
	table.sort( rot, function(a,b) return a[2]<	b[2] end )
	local newEdge={}
	for i,v in ipairs(rot) do
		newEdge[i]=self.edge[v[1]]
	end
	self.edge=newEdge
end

function soft:jointTest(c,r,tc,tr)
	tc=tc*self.step
	tr=tr*self.step
	if not self.particles[c+tc] or not self.particles[c+tc][r+tr] then return end
	local p=self.particles[c][r]
	local test=self.particles[c+tc][r+tr]
	if table.getIndex(test.connects,p.body) then return end --已经连接
	local joint = love.physics.newDistanceJoint(p.body, test.body, c, r, c+tc,r+tr, false)
	joint:setDampingRatio(0.1)
	joint:setFrequency(5)
	table.insert(p.connects,test.body)
	table.insert(test.connects,p.body)
end


function soft:connectAround(c,r)
	self:jointTest(c,r,0,-1)
	self:jointTest(c,r,1,0)
	self:jointTest(c,r,0,1)
	self:jointTest(c,r,-1,0)
	self:jointTest(c,r,1,-1)
	self:jointTest(c,r,1,1)
	self:jointTest(c,r,1,1)
	self:jointTest(c,r,-1,1)
end

function soft:draw(debug)
	if debug then
		for k1,v in pairs(self.particles) do
			for k2,v in pairs(v) do
				love.graphics.setColor(100,100,100)
				for k,b in pairs(v.connects) do
					--love.graphics.line(b:getX(), b:getY(),v.body:getX(), v.body:getY())
				end
				if v.edge then
					love.graphics.setColor(255, 0, 0)
				else
					love.graphics.setColor(0, 255, 0)
				end
				love.graphics.circle("line", v.body:getX(), v.body:getY(), self.step/2,6)
			end
		end
		love.graphics.setColor(0, 0, 255)
		love.graphics.circle("line", self.center.body:getX(), self.center.body:getY(), 10)
	else
		love.graphics.setColor(255, 255, 255)
		if self.mesh then
			love.graphics.draw(self.mesh, self.center.body:getX(), self.center.body:getY(), self.center.body:getAngle())
		else
			love.graphics.line(unpack(self.smoothPoints))
		end
	end
end

function soft:update()
	local e={}
	for i,v in ipairs(self.edge) do
		table.insert(e, v.body:getX())
		table.insert(e, v.body:getY())
	end
	--e=math.polygonTrans(0,0,0,1.01,e)
	self.smoothPoints=smooth(e)
	--self.smoothPoints=e
	self:setMesh()
end

function soft:setMesh()
	if not self.pic then return end
	local points=self.smoothPoints
	local vert={}
	table.insert(vert, {0,0,0.5,0.5})

	for i=1,#points,2 do
		local lx,ly=self.center.body:getLocalPoint(points[i],points[i+1])
		local rx=self.vertForMesh[i]/self.pic:getWidth()
		local ry=self.vertForMesh[i+1]/self.pic:getHeight()
		table.insert(vert,{lx,ly,rx,ry})
	end
	self.mesh = love.graphics.newMesh(vert, self.pic)
end

return soft