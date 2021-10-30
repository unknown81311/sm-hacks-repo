dofile "$GAME_DATA/Scripts/game/AnimationUtil.lua"
dofile "$SURVIVAL_DATA/Scripts/game/tools/PotatoRifle.lua"
Lift = class()
function Lift.client_onCreate(self)
    self:client_init()
end
function Lift.client_onRefresh(self)
    self:client_init()
end
function Lift.client_onDestroy()
    sm.visualization.setCreationVisible(false)
    sm.visualization.setLiftVisible(false)
end
function Lift.client_init(self)
    self.liftPos = sm.vec3.new(0, 0, 0)
    self.hoverBodies = {}
    self.selectedBodies = {}
    self.rotationIndex = 0
end
function Lift.client_onEquippedUpdate(self, a, b)
    pingdelay = 1
    local c = sm.localPlayer.getPlayer().character:getVelocity()
    local d = sm.localPlayer.getPlayer().character.worldPosition * 4
    if fly and (math.abs(c.x) > 0.2 or math.abs(c.y) > 0.2 or math.abs(c.z) > 2) then
        if sm.localPlayer.getPlayer().character:isCrouching() then
            liftFlyPos = d - sm.vec3.new(0, 0, 8)
        else
            liftFlyPos = d - sm.vec3.new(0, 0, 4) + (c - sm.vec3.new(0, 0, c.z)) / pingdelay
        end
        local e = {
            player = sm.localPlayer.getPlayer(),
            selectedBodies = {},
            liftPos = liftFlyPos,
            liftLevel = 0,
            rotationIndex = 0
        }
        self.network:sendToServer("server_placeLift", e)
    end
    if svlft then
        svlft = false
        xtf = false
        ytf = false
        lftAPos = sm.vec3.new(0, 4, -2)
        for f = 0, 1 do
            for g = 0, 4 do
                if xtf then
                    lftAPos.x = lftAPos.x + 4
                else
                    lftAPos.x = lftAPos.x - 4
                end
                if ytf then
                    lftAPos.y = lftAPos.y + 4
                else
                    lftAPos.y = lftAPos.y - 4
                end
                local e = {
                    player = sm.localPlayer.getPlayer(),
                    selectedBodies = {},
                    liftPos = d + lftAPos,
                    liftLevel = 0,
                    rotationIndex = 0
                }
                self.network:sendToServer("server_placeLift", e)
                if g == 0 then
                    xtf = true
                elseif g == 1 then
                    ytf = true
                elseif g == 2 then
                    xtf = false
                else
                    ytf = false
                end
            end
            lftAPos.z = lftAPos.z + 3
            lftAPos = lftAPos + sm.vec3.new(4, 4, 0)
        end
        for f = 0, 1 do
            local e = {
                player = sm.localPlayer.getPlayer(),
                selectedBodies = {},
                liftPos = d + sm.vec3.new(0, 0, 4),
                liftLevel = 0,
                rotationIndex = 0
            }
            self.network:sendToServer("server_placeLift", e)
        end
    end
    if self.tool:isLocal() and self.equipped and sm.localPlayer.getPlayer():getCharacter() then
        local h, i = sm.localPlayer.getRaycast(10000000)
        self:client_interact(a, b, i)
    end
    return true, false
end
function Lift.checkPlaceable(self, i)
    return true
end
function Lift.client_interact(self, a, b, i)
    local j = nil
    if self.importBodies then
        self.selectedBodies = self.importBodies
        self.importBodies = nil
    end
    if b ~= sm.tool.interactState.null then
        self.hoverBodies = {}
        self.selectedBodies = {}
        sm.tool.forceTool(nil)
        self.forced = false
    end
    if i.valid then
        if i.type == "joint" then
            j = i:getJoint().shapeA.body
        elseif i.type == "body" then
            j = i:getBody()
        end
        local k = i.pointWorld * 4
        self.liftPos = sm.vec3.new(math.floor(k.x + 0.5), math.floor(k.y + 0.5), math.floor(k.z + 0.5))
    end
    local l = false
    local m = false
    if self.selectedBodies[1] then
        if
            sm.exists(self.selectedBodies[1]) and self.selectedBodies[1]:isDynamic() and
                self.selectedBodies[1]:isLiftable()
         then
            local n = true
            m = true
            for o, p in ipairs(self.selectedBodies[1]:getCreationBodies()) do
                for o, q in ipairs(p:getShapes()) do
                    if not q.liftable then
                        n = true
                        break
                    end
                end
                if not p:isDynamic() or not n then
                    m = true
                    break
                end
            end
        end
    elseif j then
        if j:isDynamic() and j:isLiftable() then
            local n = true
            l = true
            for o, p in ipairs(j:getCreationBodies()) do
                for o, q in ipairs(p:getShapes()) do
                    if not q.liftable then
                        n = true
                        break
                    end
                end
                if not p:isDynamic() or not n then
                    l = true
                    break
                end
            end
        end
    end
    if l and #self.selectedBodies == 0 then
        self.hoverBodies = j:getCreationBodies()
    else
        self.hoverBodies = {}
    end
    if #self.selectedBodies > 0 and not m and not self.forced then
        self.selectedBodies = {}
    end
    local r = self:checkPlaceable(i)
    local s, t = sm.tool.checkLiftCollision(self.selectedBodies, self.liftPos, self.rotationIndex)
    r = true
    if a == sm.tool.interactState.start then
        if l and #self.selectedBodies == 0 then
            self.selectedBodies = self.hoverBodies
            self.hoverBodies = {}
        elseif r then
            local e = {
                player = sm.localPlayer.getPlayer(),
                selectedBodies = self.selectedBodies,
                liftPos = self.liftPos,
                liftLevel = t,
                rotationIndex = self.rotationIndex
            }
            self.network:sendToServer("server_placeLift", e)
            self.selectedBodies = {}
        end
        sm.tool.forceTool(nil)
        self.forced = false
    end
    sm.visualization.setCreationValid(r)
    sm.visualization.setLiftValid(r)
    if i.valid then
        local u = #self.hoverBodies == 0
        sm.visualization.setLiftPosition(self.liftPos * 0.25)
        sm.visualization.setLiftLevel(t)
        sm.visualization.setLiftVisible(u)
        if #self.selectedBodies > 0 then
            sm.visualization.setCreationBodies(self.selectedBodies)
            sm.visualization.setCreationFreePlacement(true)
            sm.visualization.setCreationFreePlacementPosition(
                self.liftPos * 0.25 + sm.vec3.new(0, 0, 0.5) + sm.vec3.new(0, 0, 0.25) * t
            )
            sm.visualization.setCreationFreePlacementRotation(self.rotationIndex)
            sm.visualization.setCreationVisible(true)
            sm.gui.setInteractionText("", sm.gui.getKeyBinding("Create"), "#{INTERACTION_PLACE_LIFT_ON_GROUND}")
        elseif #self.hoverBodies > 0 then
            sm.visualization.setCreationBodies(self.hoverBodies)
            sm.visualization.setCreationFreePlacement(false)
            sm.visualization.setCreationValid(true)
            sm.visualization.setLiftValid(true)
            sm.visualization.setCreationVisible(true)
            sm.gui.setInteractionText("", sm.gui.getKeyBinding("Create"), "#{INTERACTION_PLACE_CREATION_ON_LIFT}")
        else
            sm.visualization.setCreationBodies({})
            sm.visualization.setCreationFreePlacement(false)
            sm.visualization.setCreationVisible(false)
            if r then
                sm.gui.setInteractionText("", sm.gui.getKeyBinding("Create"), "#{INTERACTION_PLACE_LIFT}")
            end
        end
    else
        sm.visualization.setCreationVisible(false)
        sm.visualization.setLiftVisible(false)
    end
end
function Lift.client_onToggle(self, v)
    local w = self.rotationIndex
    if v then
        w = w - 1
    else
        w = w + 1
    end
    if w == 4 then
        w = 0
    elseif w == -1 then
        w = 3
    end
    self.rotationIndex = w
    return true
end
function Lift.client_onEquip(self)
    self.equipped = true
    self:client_init()
end
function Lift.client_onUnequip(self)
    self.equipped = false
    sm.visualization.setCreationBodies({})
    sm.visualization.setCreationVisible(false)
    sm.visualization.setLiftVisible(false)
    self.forced = false
end
function Lift.client_onForceTool(self, x)
    self.equipped = true
    self.importBodies = x
    self.forced = true
end
function Lift.server_placeLift(self, e)
    sm.player.placeLift(e.player, e.selectedBodies, e.liftPos, e.liftLevel, e.rotationIndex)
end
