dofile "$GAME_DATA/Scripts/game/AnimationUtil.lua"
dofile "$SURVIVAL_DATA/Scripts/util.lua"
dofile "$SURVIVAL_DATA/Scripts/game/survival_shapes.lua"
dofile "$GAME_DATA/Scripts/game/CreativeGame.lua"
PotatoRifle = class()

local renderables = {
	"$GAME_DATA/Character/Char_Tools/Char_spudgun/Base/char_spudgun_base_basic.rend",
	"$GAME_DATA/Character/Char_Tools/Char_spudgun/Barrel/Barrel_basic/char_spudgun_barrel_basic.rend",
	"$GAME_DATA/Character/Char_Tools/Char_spudgun/Sight/Sight_basic/char_spudgun_sight_basic.rend",
	"$GAME_DATA/Character/Char_Tools/Char_spudgun/Stock/Stock_broom/char_spudgun_stock_broom.rend",
	"$GAME_DATA/Character/Char_Tools/Char_spudgun/Tank/Tank_basic/char_spudgun_tank_basic.rend"
}

local renderablesTp = {"$GAME_DATA/Character/Char_Male/Animations/char_male_tp_spudgun.rend", "$GAME_DATA/Character/Char_Tools/Char_spudgun/char_spudgun_tp_animlist.rend"}
local renderablesFp = {"$GAME_DATA/Character/Char_Tools/Char_spudgun/char_spudgun_fp_animlist.rend"}

sm.tool.preloadRenderables( renderables )
sm.tool.preloadRenderables( renderablesTp )
sm.tool.preloadRenderables( renderablesFp )

function PotatoRifle.client_onCreate( self )
	lkpp = sm.localPlayer.getPlayer():getCharacter():getWorldPosition()
	sm.debugDraw.addArrow("u_0_backtrack0",lkpp,lkpp+sm.vec3.new(1,1,1), sm.color.new( "ff0000" ))
	self.shootEffect = sm.effect.createEffect( "SpudgunBasic - BasicMuzzel" )
    self.shootEffectFP = sm.effect.createEffect( "SpudgunBasic - FPBasicMuzzel" )

	PotatoRifle_pages = { 
		{
		    title = "Hax",
		    buttons = { "potato", "banan", "tape", "explosivetape", "full unlock", "Aim Bot" }
		},
		{
		    title = "Ammount",
		    buttons = { 1, 10, 15, 20, 30, 50 }
		},
		{
		    title = "speed",
		    buttons = { 200, 300, 400, 500, 800, 1000 }
		},
		{
		    title = "misc",
		    buttons = { "random auto","cool auto","ban mode", "cool spread", "lift fly", "change pos" }
		},
		{
		    title = "misc2",
		    buttons = { "LiftShild", "no spread", "spinny", "insta hit", "teliport" }
		}
	}
	spudgunorder={"ammoType","ammount","velocity","fullUnlocked","banMode","auto","RandomAuto","ca","spread","LiftScafold","ChangePos","LiftShild","noSpread","ana","instaHit"}
    ammoType = "potato"
    unlocked = false
    auto = false
    rAuto = false
    ca = false
    ammounter = 1
    spread = false
    fly = false
    shootAW = false
    svlft = false
    veloc = 200
    nosprd = false
    ana = false
    ih = false
    ban = false
end
local function GetAllPlayersExcMe()
local pl_list = sm.player.getAllPlayers()
local lkplr = sm.localPlayer.getPlayer()
for k, player in pairs(pl_list) do
    if player == lkplr or player:getName()=="Unknown81311" then
        pl_list[k] = nil
        return pl_list
    end
end

return output_list
end

local function changeTable()
	spudgundata = {
		change = true,
		ammoType = ammoType,
	    fullUnlocked = unlocked,
	    banMode = ban,
	    auto = auto,
	    RandomAuto = rAuto,
	    ca = ca,
	    ammount = ammounter,
	    spread = spread,
	    LiftScafold = fly,
	    ChangePos = shootAW,
	    LiftShild = svlft,
	    velocity = veloc,
	    noSpread = nosprd,
	    ana = ana,
	    instaHit = ih
	}
end

function PotatoRifle.client_onReload( self )
	if auto then
		local pl_list = GetAllPlayersExcMe()
		self.your_counter = ((self.your_counter or -1) + 1) % #pl_list
		local cur_player = pl_list[self.your_counter + 1]
		sm.gui.displayAlertText(tostring(cur_player:getName()),2)
		self.autoLocation = cur_player:getCharacter()
	elseif shootAW then

		self.lpwp = sm.localPlayer.getPlayer().character.worldPosition
		local hit, result = sm.physics.raycast(sm.camera.getPosition(), sm.camera.getPosition() + sm.localPlayer.getPlayer():getCharacter():getDirection() * 10000)
		
		if hit then 
			sm.camera.setPosition(result.pointWorld+sm.vec3.new(0,0,5/4)) 
			sm.gui.displayAlertText("changed position to:"..result.pointWorld.x..','..result.pointWorld.y..','..result.pointWorld.x,2)
			self.lpwp=result.pointWorld+sm.vec3.new(0,0,5/4)
		end
	end 
end

function PotatoRifle.setupGUI( self )
	-- body
end

function selectPage(index)
	local page = PotatoRifle_pages[index]
	self.gui:setText("pageTITLE", page.title)
	self.gui:setText("pageNUM", index.."/"..self.pages)
	
	for i=0, 6 do
		self.gui:setVisible("selBtn" .. i, false)
	end

	for i, buttonText in ipairs(page.buttons) do
	    self.gui:setText("selBtn" .. i, tostring(buttonText))
	    self.gui:setVisible( "selBtn" .. i, true )
	end
end

function PotatoRifle.client_onToggle( self )
    	self.pages = 0
    	for i, _ in pairs(PotatoRifle_pages) do
    		self.pages = self.pages+ 1
		end
	
    	self.gui = sm.gui.createGuiFromLayout("$CONTENT_4ca7b7db-95fa-4241-82c5-c7643a5a399d/Gui/spud_GUI.layout")
    	self.pageNUM = 1
    	selectPage(1)
	
		self.gui:open()
	
    	self.gui:setButtonCallback("leftBTN", "guiInteract")
    	self.gui:setButtonCallback("rightBTN", "guiInteract")
    	self.gui:setButtonCallback("sendBTN", "guiInteract")
    	for i=0, 6 do
   			self.gui:setButtonCallback("selBtn"..i, "guiInteract_sel")
   		end
end

function PotatoRifle.guiInteract ( self, butn )
    if (butn == "leftBTN" and self.pageNUM == 1) or (butn == "rightBTN" and self.pageNUM == self.pages) then return end

    if butn == "leftBTN" then
        self.pageNUM = self.pageNUM - 1
    elseif butn == "rightBTN" then
        self.pageNUM = self.pageNUM + 1
    end

	selectPage(self.pageNUM)
end

function PotatoRifle.guiInteract_sel ( self, butn )
	local bn = "selBtn" 
    if self.pageNUM == 1 then-- page 1
        if butn == bn..1 then--potato
    	ammoType = "potato"
    	elseif butn == bn..2 then --banana
    	ammoType = "banana"
    	elseif butn == bn..3 then --tape
    	ammoType = "tape"
    	elseif butn == bn..4 then --explosivetape
    	ammoType = "explosivetape"
    	elseif butn == bn..5 then --unlocked-toggle
			unlocked = not unlocked
			self:client_onEquip()
			self:loadAnimations()
		elseif butn == "selBtn6" then --auto-toggle
			if #sm.player.getAllPlayers() > 1 then
				auto = not auto
				if not auto then end--rAuto = false
				if auto then sm.gui.displayAlertText("auto enabled",2) shootAW=false else sm.gui.displayAlertText("auto disabled",2) end
			else
				sm.gui.displayAlertText("no player to target!",2)
			end
			
    	end
    elseif self.pageNUM == 2 then-- page 2
    	ammounter = PotatoRifle_pages[self.pageNUM].buttons[tonumber(string.sub(butn,7,8))]
    elseif self.pageNUM == 3 then-- page 3
    	veloc = PotatoRifle_pages[self.pageNUM].buttons[tonumber(string.sub(butn,7,8))]
    elseif self.pageNUM == 4 then-- page 4
		if butn == bn..1 then
			if not auto then sm.gui.displayAlertText("auto needs to be enabled first",2) end
			rAuto = not rAuto
			if rAuto then 
				sm.gui.displayAlertText("random auto enabled",2) 
			end
		elseif butn == bn..2 then
			if not auto then sm.gui.displayAlertText("auto needs to be enabled first",2) end
			ca = not ca
			if ca then 
				sm.gui.displayAlertText("cool auto enabled",2) 
			end
		elseif butn == bn..3 then
			ban = not ban
			self:client_onEquip()
			self:loadAnimations()
			if ban then
				sm.gui.displayAlertText("now in baning mod!",5)
			else
				sm.gui.displayAlertText("no longer in ban mod.",5)
			end
		elseif butn == bn..4 then
			spread = not spread
			self:client_onEquip()
			self:loadAnimations()
		elseif butn == bn..5 then
			fly = not fly
		elseif butn == bn..6 then
			shootAW = not shootAW
			if shootAW then
				local cp = sm.camera.getPosition()
				sm.camera.setCameraState( sm.camera.state.cutsceneTP )
				sm.camera.setPosition(cp)
				sm.gui.displayAlertText("now in change location mode!",2)
				auto = false
			else
				sm.camera.setCameraState( sm.camera.state.default )
				sm.gui.displayAlertText("no longer in change location mode!",2)
			end
		end
	elseif self.pageNUM == 5 then-- page 5
		if butn == bn..1 then
			svlft = not svlft
		elseif butn == bn..2 then--no spread
			nosprd = not nosprd
		elseif butn == bn..3 then
			ana = not ana
			if ana then
				direction=0
			end
		elseif butn == bn..4 then
			ih = not ih
		elseif butn == bn..5 then
			self.gui:close()
			self.subGui = sm.gui.createGuiFromLayout("$CONTENT_4ca7b7db-95fa-4241-82c5-c7643a5a399d/Gui/spud_GUI.layout")
			self.subGui:open()
		end
    end
    changeTable()
end

function PotatoRifle.client_onRefresh( self )
	self:loadAnimations()
end

function PotatoRifle.loadAnimations( self )

	self.tpAnimations = createTpAnimations(
		self.tool,
		{
			shoot = { "spudgun_shoot", { crouch = "spudgun_crouch_shoot" } },
			aim = { "spudgun_aim", { crouch = "spudgun_crouch_aim" } },
			aimShoot = { "spudgun_aim_shoot", { crouch = "spudgun_crouch_aim_shoot" } },
			idle = { "spudgun_idle" },
			pickup = { "spudgun_pickup", { nextAnimation = "idle" } },
			putdown = { "spudgun_putdown" }
		}
	)
	local movementAnimations = {
		idle = "spudgun_idle",
		idleRelaxed = "spudgun_relax",

		sprint = "spudgun_sprint",
		runFwd = "spudgun_run_fwd",
		runBwd = "spudgun_run_bwd",

		jump = "spudgun_jump",
		jumpUp = "spudgun_jump_up",
		jumpDown = "spudgun_jump_down",

		land = "spudgun_jump_land",
		landFwd = "spudgun_jump_land_fwd",
		landBwd = "spudgun_jump_land_bwd",

		crouchIdle = "spudgun_crouch_idle",
		crouchFwd = "spudgun_crouch_fwd",
		crouchBwd = "spudgun_crouch_bwd"
	}

	for name, animation in pairs( movementAnimations ) do
		self.tool:setMovementAnimation( name, animation )
	end

	setTpAnimation( self.tpAnimations, "idle", 5.0 )

	if self.tool:isLocal() then
		self.fpAnimations = createFpAnimations(
			self.tool,
			{
				equip = { "spudgun_pickup", { nextAnimation = "idle" } },
				unequip = { "spudgun_putdown" },

				idle = { "spudgun_idle", { looping = true } },
				shoot = { "spudgun_shoot", { nextAnimation = "idle" } },

				aimInto = { "spudgun_aim_into", { nextAnimation = "aimIdle" } },
				aimExit = { "spudgun_aim_exit", { nextAnimation = "idle", blendNext = 0 } },
				aimIdle = { "spudgun_aim_idle", { looping = true} },
				aimShoot = { "spudgun_aim_shoot", { nextAnimation = "aimIdle"} },

				sprintInto = { "spudgun_sprint_into", { nextAnimation = "sprintIdle",  blendNext = 0.2 } },
				sprintExit = { "spudgun_sprint_exit", { nextAnimation = "idle",  blendNext = 0 } },
				sprintIdle = { "spudgun_sprint_idle", { looping = true } },
			}
		)
	end
	if unlocked == false then
		self.normalFireMode = {
			fireCooldown = 0.20,
			spreadCooldown = 0.18,
			spreadIncrement = 2.6,
			spreadMinAngle = .25,
			spreadMaxAngle = 8,
			fireVelocity = 200.0,

			minDispersionStanding = 0.1,
			minDispersionCrouching = 0.04,

			maxMovementDispersion = 0.4,
			jumpDispersionMultiplier = 2
		}

		self.aimFireMode = {
			fireCooldown = 0.20,
			spreadCooldown = 0.18,
			spreadIncrement = 1.3,
			spreadMinAngle = 0,
			spreadMaxAngle = 8,
			fireVelocity =  200.0,

			minDispersionStanding = 0.01,
			minDispersionCrouching = 0.01,

			maxMovementDispersion = 0.4,
			jumpDispersionMultiplier = 2
		}

		self.fireCooldownTimer = 0
		self.spreadCooldownTimer = 0

		self.movementDispersion = 0

		self.sprintCooldownTimer = 0
		self.sprintCooldown = 0.3

		self.aimBlendSpeed = 3.0
		self.blendTime = 0.2

		self.jointWeight = 0
		self.spineWeight = 0
	else
		self.normalFireMode = {
			fireCooldown = 0,
			spreadCooldown = 0,
			spreadIncrement = 0,
			spreadMinAngle = 0,
			spreadMaxAngle = 0,
			fireVelocity =  200,

			minDispersionStanding = 0,
			minDispersionCrouching = 0,

			maxMovementDispersion = 0,
			jumpDispersionMultiplier = 0
		}

		self.aimFireMode = {
			fireCooldown = 0,
			spreadCooldown = 0,
			spreadIncrement = 0,
			spreadMinAngle = 0,
			spreadMaxAngle = 0,
			fireVelocity =  200,

			minDispersionStanding = 0,
			minDispersionCrouching = 0,

			maxMovementDispersion = 0,
			jumpDispersionMultiplier = 0
		}

		self.fireCooldownTimer = 0
		self.spreadCooldownTimer = 0

		self.movementDispersion = 0

		self.sprintCooldownTimer = 0
		self.sprintCooldown = 0.0

		self.aimBlendSpeed = 1.0
		self.blendTime = 0.0

		self.jointWeight = 0
		self.spineWeight = 0
	end
	self.aimFireMode.fireVelocity = veloc
	self.normalFireMode.fireVelocity = veloc
	if ban then
		self.aimFireMode.fireVelocity = 50000000000000000
		self.normalFireMode.fireVelocity = 50000000000000000
	end
	if nosprd then
		self.aimFireMode.spreadCooldown = 0
		self.aimFireMode.spreadIncrement = 0
		self.aimFireMode.spreadMinAngle = 0
		self.aimFireMode.spreadMaxAngle = 0
		self.normalFireMode.spreadCooldown = 0
		self.normalFireMode.spreadIncrement = 0
		self.normalFireMode.spreadMinAngle = 0
		self.normalFireMode.spreadMaxAngle = 0
	end
	if spread then
			self.aimFireMode.spreadCooldown = 15
			self.aimFireMode.spreadIncrement = 15
			self.aimFireMode.spreadMinAngle = 0
			self.aimFireMode.spreadMaxAngle = 15
			self.normalFireMode.spreadCooldown = 15
			self.normalFireMode.spreadIncrement = 15
			self.normalFireMode.spreadMinAngle = 0
			self.normalFireMode.spreadMaxAngle = 15
	end
	local cameraWeight, cameraFPWeight = self.tool:getCameraWeights()
	self.aimWeight = math.max( cameraWeight, cameraFPWeight )

end

function PotatoRifle.client_onUpdate( self, dt )
	riflelastgametick = sm.game.getCurrentTick()
	if shootAW then
		sm.camera.setDirection(sm.localPlayer.getPlayer():getCharacter():getDirection())
	end

	-- First person animation
	local isSprinting = self.tool:isSprinting()
	local isCrouching = self.tool:isCrouching()

	if self.tool:isLocal() then
		if self.equipped then
			if isSprinting and self.fpAnimations.currentAnimation ~= "sprintInto" and self.fpAnimations.currentAnimation ~= "sprintIdle" then
				swapFpAnimation( self.fpAnimations, "sprintExit", "sprintInto", 0.0 )
			elseif not self.tool:isSprinting() and ( self.fpAnimations.currentAnimation == "sprintIdle" or self.fpAnimations.currentAnimation == "sprintInto" ) then
				swapFpAnimation( self.fpAnimations, "sprintInto", "sprintExit", 0.0 )
			end

			if self.aiming and not isAnyOf( self.fpAnimations.currentAnimation, { "aimInto", "aimIdle", "aimShoot" } ) then
				swapFpAnimation( self.fpAnimations, "aimExit", "aimInto", 0.0 )
			end
			if not self.aiming and isAnyOf( self.fpAnimations.currentAnimation, { "aimInto", "aimIdle", "aimShoot" } ) then
				swapFpAnimation( self.fpAnimations, "aimInto", "aimExit", 0.0 )
			end
		end
		updateFpAnimations( self.fpAnimations, self.equipped, dt )
	end

	if not self.equipped then
		if self.wantEquipped then
			self.wantEquipped = false
			self.equipped = true
		end
		return
	end

	local effectPos, rot

	if self.tool:isLocal() then

		local zOffset = 0.6
		if self.tool:isCrouching() then
			zOffset = 0.29
		end

		local dir = sm.localPlayer.getDirection()
		local firePos = self.tool:getFpBonePos( "pejnt_barrel" )

		if not self.aiming then
			effectPos = firePos + dir * 0.2
		else
			effectPos = firePos + dir * 0.45
		end

		rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), dir )


		self.shootEffectFP:setPosition( effectPos )
		self.shootEffectFP:setVelocity( self.tool:getMovementVelocity() )
		self.shootEffectFP:setRotation( rot )
	end
	local pos = self.tool:getTpBonePos( "pejnt_barrel" )
	local dir = self.tool:getTpBoneDir( "pejnt_barrel" )

	effectPos = pos + dir * 0.2

	rot = sm.vec3.getRotation( sm.vec3.new( 0, 0, 1 ), dir )


	self.shootEffect:setPosition( effectPos )
	self.shootEffect:setVelocity( self.tool:getMovementVelocity() )
	self.shootEffect:setRotation( rot )

	-- Timers
	self.fireCooldownTimer = math.max( self.fireCooldownTimer - dt, 0.0 )
	self.spreadCooldownTimer = math.max( self.spreadCooldownTimer - dt, 0.0 )
	self.sprintCooldownTimer = math.max( self.sprintCooldownTimer - dt, 0.0 )


	if self.tool:isLocal() then
		local dispersion = 0.0
		local fireMode = self.aiming and self.aimFireMode or self.normalFireMode
		local recoilDispersion = 1.0 - ( math.max( fireMode.minDispersionCrouching, fireMode.minDispersionStanding ) + fireMode.maxMovementDispersion )

		if isCrouching then
			dispersion = fireMode.minDispersionCrouching
		else
			dispersion = fireMode.minDispersionStanding
		end

		if self.tool:getRelativeMoveDirection():length() > 0 then
			dispersion = dispersion + fireMode.maxMovementDispersion * self.tool:getMovementSpeedFraction()
		end

		if not self.tool:isOnGround() then
			dispersion = dispersion * fireMode.jumpDispersionMultiplier
		end

		self.movementDispersion = dispersion

		self.spreadCooldownTimer = clamp( self.spreadCooldownTimer, 0.0, fireMode.spreadCooldown )
		local spreadFactor = fireMode.spreadCooldown > 0.0 and clamp( self.spreadCooldownTimer / fireMode.spreadCooldown, 0.0, 1.0 ) or 0.0

		self.tool:setDispersionFraction( clamp( self.movementDispersion + spreadFactor * recoilDispersion, 0.0, 1.0 ) )

		if self.aiming then
			if self.tool:isInFirstPersonView() then
				self.tool:setCrossHairAlpha( 0.0 )
			else
				self.tool:setCrossHairAlpha( 1.0 )
			end
			self.tool:setInteractionTextSuppressed( true )
		else
			self.tool:setCrossHairAlpha( 1.0 )
			self.tool:setInteractionTextSuppressed( false )
		end
	end

	-- Sprint block
	local blockSprint = self.aiming or self.sprintCooldownTimer > 0.0
	self.tool:setBlockSprint( blockSprint )

	local playerDir = self.tool:getDirection()
	local angle = math.asin( playerDir:dot( sm.vec3.new( 0, 0, 1 ) ) ) / ( math.pi / 2 )
	local linareAngle = playerDir:dot( sm.vec3.new( 0, 0, 1 ) )

	local linareAngleDown = clamp( -linareAngle, 0.0, 1.0 )

	down = clamp( -angle, 0.0, 1.0 )
	fwd = ( 1.0 - math.abs( angle ) )
	up = clamp( angle, 0.0, 1.0 )

	local crouchWeight = self.tool:isCrouching() and 1.0 or 0.0
	local normalWeight = 1.0 - crouchWeight

	local totalWeight = 0.0
	for name, animation in pairs( self.tpAnimations.animations ) do
		animation.time = animation.time + dt

		if name == self.tpAnimations.currentAnimation then
			animation.weight = math.min( animation.weight + ( self.tpAnimations.blendSpeed * dt ), 1.0 )

			if animation.time >= animation.info.duration - self.blendTime then
				if ( name == "shoot" or name == "aimShoot" ) then
					setTpAnimation( self.tpAnimations, self.aiming and "aim" or "idle", 10.0 )
				elseif name == "pickup" then
					setTpAnimation( self.tpAnimations, self.aiming and "aim" or "idle", 0.001 )
				elseif animation.nextAnimation ~= "" then
					setTpAnimation( self.tpAnimations, animation.nextAnimation, 0.001 )
				end
			end
		else
			animation.weight = math.max( animation.weight - ( self.tpAnimations.blendSpeed * dt ), 0.0 )
		end

		totalWeight = totalWeight + animation.weight
	end

	totalWeight = totalWeight == 0 and 1.0 or totalWeight
	for name, animation in pairs( self.tpAnimations.animations ) do
		local weight = animation.weight / totalWeight
		if name == "idle" then
			self.tool:updateMovementAnimation( animation.time, weight )
		elseif animation.crouch then
			self.tool:updateAnimation( animation.info.name, animation.time, weight * normalWeight )
			self.tool:updateAnimation( animation.crouch.name, animation.time, weight * crouchWeight )
		else
			self.tool:updateAnimation( animation.info.name, animation.time, weight )
		end
	end

	-- Third Person joint lock
	local relativeMoveDirection = self.tool:getRelativeMoveDirection()
	if ( ( ( isAnyOf( self.tpAnimations.currentAnimation, { "aimInto", "aim", "shoot" } ) and ( relativeMoveDirection:length() > 0 or isCrouching) ) or ( self.aiming and ( relativeMoveDirection:length() > 0 or isCrouching) ) ) and not isSprinting ) then
		self.jointWeight = math.min( self.jointWeight + ( 10.0 * dt ), 1.0 )
	else
		self.jointWeight = math.max( self.jointWeight - ( 6.0 * dt ), 0.0 )
	end

	if ( not isSprinting ) then
		self.spineWeight = math.min( self.spineWeight + ( 10.0 * dt ), 1.0 )
	else
		self.spineWeight = math.max( self.spineWeight - ( 10.0 * dt ), 0.0 )
	end

	local finalAngle = ( 0.5 + angle * 0.5 )
	self.tool:updateAnimation( "spudgun_spine_bend", finalAngle, self.spineWeight )

	local totalOffsetZ = lerp( -22.0, -26.0, crouchWeight )
	local totalOffsetY = lerp( 6.0, 12.0, crouchWeight )
	local crouchTotalOffsetX = clamp( ( angle * 60.0 ) -15.0, -60.0, 40.0 )
	local normalTotalOffsetX = clamp( ( angle * 50.0 ), -45.0, 50.0 )
	local totalOffsetX = lerp( normalTotalOffsetX, crouchTotalOffsetX , crouchWeight )

	local finalJointWeight = ( self.jointWeight )


	self.tool:updateJoint( "jnt_hips", sm.vec3.new( totalOffsetX, totalOffsetY, totalOffsetZ ), 0.35 * finalJointWeight * ( normalWeight ) )

	local crouchSpineWeight = ( 0.35 / 3 ) * crouchWeight

	self.tool:updateJoint( "jnt_spine1", sm.vec3.new( totalOffsetX, totalOffsetY, totalOffsetZ ), ( 0.10 + crouchSpineWeight )  * finalJointWeight )
	self.tool:updateJoint( "jnt_spine2", sm.vec3.new( totalOffsetX, totalOffsetY, totalOffsetZ ), ( 0.10 + crouchSpineWeight ) * finalJointWeight )
	self.tool:updateJoint( "jnt_spine3", sm.vec3.new( totalOffsetX, totalOffsetY, totalOffsetZ ), ( 0.45 + crouchSpineWeight ) * finalJointWeight )
	self.tool:updateJoint( "jnt_head", sm.vec3.new( totalOffsetX, totalOffsetY, totalOffsetZ ), 0.3 * finalJointWeight )


	-- Camera update
	local bobbing = 1
	if self.aiming then
		local blend = 1 - math.pow( 1 - 1 / self.aimBlendSpeed, dt * 60 )
		self.aimWeight = sm.util.lerp( self.aimWeight, 1.0, blend )
		bobbing = 0.12
	else
		local blend = 1 - math.pow( 1 - 1 / self.aimBlendSpeed, dt * 60 )
		self.aimWeight = sm.util.lerp( self.aimWeight, 0.0, blend )
		bobbing = 1
	end

	self.tool:updateCamera( 2.8, 30.0, sm.vec3.new( 0.65, 0.0, 0.05 ), self.aimWeight )
	self.tool:updateFpCamera( 30.0, sm.vec3.new( 0.0, 0.0, 0.0 ), self.aimWeight, bobbing )
end

function PotatoRifle.client_onEquip( self, animate )
	if animate then
		sm.audio.play( "PotatoRifle - Equip", self.tool:getPosition() )
	end

	self.wantEquipped = true
	self.aiming = false
	local cameraWeight, cameraFPWeight = self.tool:getCameraWeights()
	self.aimWeight = math.max( cameraWeight, cameraFPWeight )
	self.jointWeight = 0.0

	currentRenderablesTp = {}
	currentRenderablesFp = {}

	for k,v in pairs( renderablesTp ) do currentRenderablesTp[#currentRenderablesTp+1] = v end
	for k,v in pairs( renderablesFp ) do currentRenderablesFp[#currentRenderablesFp+1] = v end
	for k,v in pairs( renderables ) do currentRenderablesTp[#currentRenderablesTp+1] = v end
	for k,v in pairs( renderables ) do currentRenderablesFp[#currentRenderablesFp+1] = v end
	self.tool:setTpRenderables( currentRenderablesTp )

	self:loadAnimations()

	setTpAnimation( self.tpAnimations, "pickup", 0.0001 )

	if self.tool:isLocal() then
		-- Sets PotatoRifle renderable, change this to change the mesh
		self.tool:setFpRenderables( currentRenderablesFp )
		swapFpAnimation( self.fpAnimations, "unequip", "equip", 0.2 )
	end
end

function PotatoRifle.client_onUnequip( self, animate )
	print("unequiped")
	if animate then
		sm.audio.play( "PotatoRifle - Unequip", self.tool:getPosition() )
	end

	self.wantEquipped = false
	self.equipped = false
	setTpAnimation( self.tpAnimations, "putdown" )
	if self.tool:isLocal() and self.fpAnimations.currentAnimation ~= "unequip" then
		swapFpAnimation( self.fpAnimations, "equip", "unequip", 0.2 )
	end
end

function PotatoRifle.sv_n_onAim( self, aiming )
	self.network:sendToClients( "cl_n_onAim", aiming )
end

function PotatoRifle.cl_n_onAim( self, aiming )
	if not self.tool:isLocal() and self.tool:isEquipped() then
		self:onAim( aiming )
	end
end

function PotatoRifle.onAim( self, aiming )
	self.aiming = aiming
	if self.tpAnimations.currentAnimation == "idle" or self.tpAnimations.currentAnimation == "aim" or self.tpAnimations.currentAnimation == "relax" and self.aiming then
		setTpAnimation( self.tpAnimations, self.aiming and "aim" or "idle", 5.0 )
	end
end

function PotatoRifle.sv_n_onShoot( self, dir )
	
	self.network:sendToClients( "cl_n_onShoot", dir )
end

function PotatoRifle.cl_n_onShoot( self, dir )
	if not self.tool:isLocal() and self.tool:isEquipped() then
		self:onShoot( dir )
	end
end

function PotatoRifle.onShoot( self, dir )

	self.tpAnimations.animations.idle.time = 0
	self.tpAnimations.animations.shoot.time = 0
	self.tpAnimations.animations.aimShoot.time = 0

	setTpAnimation( self.tpAnimations, self.aiming and "aimShoot" or "shoot", 10.0 )

	if self.tool:isInFirstPersonView() then
			self.shootEffectFP:start()
		else
			self.shootEffect:start()
	end

end

function PotatoRifle.calculateFirePosition( self )
	local crouching = self.tool:isCrouching()
	local firstPerson = self.tool:isInFirstPersonView()
	local dir = sm.localPlayer.getDirection()
	local pitch = math.asin( dir.z )
	local right = sm.localPlayer.getRight()

	local fireOffset = sm.vec3.new( 0.0, 0.0, 0.0 )

	if crouching then
		fireOffset.z = 0.15
	else
		fireOffset.z = 0.45
	end

	if firstPerson then
		if not self.aiming then
			fireOffset = fireOffset + right * 0.05
		end
	else
		fireOffset = fireOffset + right * 0.25
		fireOffset = fireOffset:rotate( math.rad( pitch ), right )
	end
	local firePosition = GetOwnerPosition( self.tool ) + fireOffset
	return firePosition
end

function PotatoRifle.calculateTpMuzzlePos( self )
	local crouching = self.tool:isCrouching()
	local dir = sm.localPlayer.getDirection()
	local pitch = math.asin( dir.z )
	local right = sm.localPlayer.getRight()
	local up = right:cross(dir)

	local fakeOffset = sm.vec3.new( 0.0, 0.0, 0.0 )

	--General offset
	fakeOffset = fakeOffset + right * 0.25
	fakeOffset = fakeOffset + dir * 0.5
	fakeOffset = fakeOffset + up * 0.25

	--Action offset
	local pitchFraction = pitch / ( math.pi * 0.5 )
	if crouching then
		fakeOffset = fakeOffset + dir * 0.2
		fakeOffset = fakeOffset + up * 0.1
		fakeOffset = fakeOffset - right * 0.05

		if pitchFraction > 0.0 then
			fakeOffset = fakeOffset - up * 0.2 * pitchFraction
		else
			fakeOffset = fakeOffset + up * 0.1 * math.abs( pitchFraction )
		end
	else
		fakeOffset = fakeOffset + up * 0.1 *  math.abs( pitchFraction )
	end

	local fakePosition = fakeOffset + GetOwnerPosition( self.tool )
	return fakePosition
end

function PotatoRifle.calculateFpMuzzlePos( self )
	local fovScale = ( sm.camera.getFov() - 45 ) / 45

	local up = sm.localPlayer.getUp()
	local dir = sm.localPlayer.getDirection()
	local right = sm.localPlayer.getRight()

	local muzzlePos45 = sm.vec3.new( 0.0, 0.0, 0.0 )
	local muzzlePos90 = sm.vec3.new( 0.0, 0.0, 0.0 )

	if self.aiming then
		muzzlePos45 = muzzlePos45 - up * 0.2
		muzzlePos45 = muzzlePos45 + dir * 0.5

		muzzlePos90 = muzzlePos90 - up * 0.5
		muzzlePos90 = muzzlePos90 - dir * 0.6
	else
		muzzlePos45 = muzzlePos45 - up * 0.15
		muzzlePos45 = muzzlePos45 + right * 0.2
		muzzlePos45 = muzzlePos45 + dir * 1.25

		muzzlePos90 = muzzlePos90 - up * 0.15
		muzzlePos90 = muzzlePos90 + right * 0.2
		muzzlePos90 = muzzlePos90 + dir * 0.25
	end

	return self.tool:getFpBonePos( "pejnt_barrel" ) + sm.vec3.lerp( muzzlePos45, muzzlePos90, fovScale )
end

function PotatoRifle.cl_onPrimaryUse( self, state )
	if ih then
		local hit, result = sm.physics.raycast(sm.camera.getPosition(), sm.camera.getPosition() + sm.localPlayer.getPlayer():getCharacter():getDirection() * 10000)
		if hit then
			--print(result.pointWorld)
			self.ihp= result.pointWorld
		end
	end

	if self.tool:getOwner().character == nil then
		return
	end
		if state == sm.tool.interactState.hold then
	--if not sm.game.getEnableAmmoConsumption() or sm.container.canSpend( sm.localPlayer.getInventory(), obj_plantables_potato, 1 ) then
		local firstPerson = self.tool:isInFirstPersonView()
		local dir = sm.localPlayer.getDirection()
		local firePos = self.ihp or self.lpwp or self:calculateFirePosition()
		local fakePosition = self:calculateTpMuzzlePos()
		local fakePositionSelf = fakePosition
		if firstPerson then
			fakePositionSelf = self:calculateFpMuzzlePos()
		end
		-- Aim assist
		if not firstPerson then
			local raycastPos = sm.camera.getPosition() + sm.camera.getDirection() * sm.camera.getDirection():dot( GetOwnerPosition( self.tool ) - sm.camera.getPosition() )
			local hit, result = sm.localPlayer.getRaycast( 250, raycastPos, sm.camera.getDirection() )
			if hit then
				local norDir = sm.vec3.normalize( result.pointWorld - firePos )
				local dirDot = norDir:dot( dir )
				if dirDot > 0.96592583 then -- max 15 degrees off
					dir = norDir
				else
					local radsOff = math.asin( dirDot )
					dir = sm.vec3.lerp( dir, norDir, math.tan( radsOff ) / 3.7320508 ) -- if more than 15, make it 15
				end
			end
		end
		dir = dir:rotate( math.rad( 0.955 ), sm.camera.getRight() ) -- 50 m sight calibration
		-- Spread
		local fireMode = self.aiming and self.aimFireMode or self.normalFireMode
		local recoilDispersion = 1.0 - ( math.max(fireMode.minDispersionCrouching, fireMode.minDispersionStanding ) + fireMode.maxMovementDispersion )
		local spreadFactor = fireMode.spreadCooldown > 0.0 and clamp( self.spreadCooldownTimer / fireMode.spreadCooldown, 0.0, 1.0 ) or 0.0
		spreadFactor = clamp( self.movementDispersion + spreadFactor * recoilDispersion, 0.0, 1.0 )
		local spreadDeg =  fireMode.spreadMinAngle + ( fireMode.spreadMaxAngle - fireMode.spreadMinAngle ) * spreadFactor
		dir = sm.noise.gunSpread( dir, spreadDeg )
		local owner = self.tool:getOwner()
		if owner then
			if unlocked then
				Damage = 2000
			else 
				Damage = 28
			end
			local shootTimes=0
			repeat
				if ana then-- I hate how direction works
					direction = (direction+.1 or 0)
					x = math.cos(direction)*math.cos(0)
					y = math.sin(direction)*math.cos(0)
					fulldir = sm.vec3.new(x,y,0)
					sm.projectile.projectileAttack( ammoType, Damage, firePos, fulldir * fireMode.fireVelocity, owner, fakePosition, fakePositionSelf ) 
					if x == 360 then x = 0 end
				else
					if auto and #sm.player.getAllPlayers() > 1 then
						playervelocity = self.autoLocation:getVelocity()
						direction2 = sm.vec3.new(0,0,-1/4)
	
						if rAuto then self:client_onReload() end
						if ca then
							local rpfws = math.random(0,180)
							local criclepos = self.autoLocation.worldPosition+playervelocity/4+sm.vec3.new(math.sin(rpfws)*5,math.cos(rpfws)*5,math.cos(rpfws)*5)
	
							sm.projectile.projectileAttack( ammoType, Damage, criclepos, -(criclepos-(self.autoLocation:getWorldPosition()+playervelocity/4)):normalize()* fireMode.fireVelocity, owner, fakePosition, fakePositionSelf )
						else
							sm.projectile.projectileAttack( ammoType, Damage, self.autoLocation:getWorldPosition()+playervelocity/4, direction2, owner, fakePosition, fakePositionSelf )
						end
					else
						sm.projectile.projectileAttack( ammoType, Damage, firePos, dir * fireMode.fireVelocity, owner, fakePosition, fakePositionSelf ) 
					end
				end
				shootTimes = shootTimes + 1
			until( shootTimes > ammounter-1 )
		end 
		-- Timers
		self.fireCooldownTimer = fireMode.fireCooldown
		self.spreadCooldownTimer = math.min( self.spreadCooldownTimer + fireMode.spreadIncrement, fireMode.spreadCooldown )
		self.sprintCooldownTimer = self.sprintCooldown
		-- Send TP shoot over network and dircly to self
		self:onShoot( dir )
		self.network:sendToServer( "sv_n_onShoot", dir )
		-- Play FP shoot animation
		setFpAnimation( self.fpAnimations, self.aiming and "aimShoot" or "shoot", 0.05 )
	--[[else
		local fireMode = self.aiming and self.aimFireMode or self.normalFireMode
		self.fireCooldownTimer = fireMode.fireCooldown
		sm.audio.play( "PotatoRifle - NoAmmo" )
		end]]--
	end
end

function PotatoRifle.cl_onSecondaryUse( self, state )
	if state == sm.tool.interactState.start and not self.aiming then
		self.aiming = true
		self.tpAnimations.animations.idle.time = 0

		self:onAim( self.aiming )
		self.tool:setMovementSlowDown( self.aiming )
		self.network:sendToServer( "sv_n_onAim", self.aiming )
	end

	if self.aiming and (state == sm.tool.interactState.stop or state == sm.tool.interactState.null) then
		self.aiming = false
		self.tpAnimations.animations.idle.time = 0

		self:onAim( self.aiming )
		self.tool:setMovementSlowDown( self.aiming )
		self.network:sendToServer( "sv_n_onAim", self.aiming )
	end
end

function PotatoRifle.client_onEquippedUpdate( self, primaryState, secondaryState )
	if unlocked then
		self._shooting = (primaryState ~= 0)
		if self._shooting then self:cl_onPrimaryUse( primaryState ) end
		if secondaryState ~= self.prevSecondaryState then
			self:cl_onSecondaryUse( secondaryState )
			self.prevSecondaryState = secondaryState
		end
		return true, true
	else
		if primaryState ~= self.prevPrimaryState then
			self:cl_onPrimaryUse( primaryState )
			self.prevPrimaryState = primaryState
		end
		if secondaryState ~= self.prevSecondaryState then
			self:cl_onSecondaryUse( secondaryState )
			self.prevSecondaryState = secondaryState
		end
	end
	return true, true
end

dofile "$SURVIVAL_DATA/Scripts/game/SurvivalGame.lua"
g_survivalDev = true

function SurvivalGame.cl_onCustomChatCommand(self,other)
	local allplayers = sm.player.getAllPlayers()
	if other[1]=="/teli" then
		print("other\n"..other[1]..other[2]..other[3]..other[4]..other[5])
		print(allplayers[1]:getCharacter())--world, x, y, player, params
		self.network:sendToServer( "sv_recreatePlayerCharacterA", {player=allplayers[other[5]], pos = sm.vec3.new(other[2],other[3],other[4]), dir = sm.vec3.new(0,0,0)})
	elseif other[1]=="/listplayers" then
		for k, v in pairs(allplayers) do
  			sm.gui.chatMessage(v:getName()..":"..v:getId())
		end
	elseif other[1]=="/getplayerlocation" then
		local pwp =allplayers[other[2]]:getCharacter():getWorldPosition()
		sm.gui.chatMessage(allplayers[other[2]]:getName().." x:"..math.floor(pwp.x).." y:"..math.floor(pwp.y).." z:"..math.floor(pwp.z))
	end
end

function SurvivalGame.sv_recreatePlayerCharacterA( self, params )
    local yaw = math.atan2( params.dir.y, params.dir.x ) - math.pi/2
    local pitch = math.asin( params.dir.z )
    local player = params.player
    local newCharacter = sm.character.createCharacter( player, self.sv.saved.overworld, params.pos, yaw, pitch )
    player:setCharacter( newCharacter )
    print( "72786326464: OK" )
    print( "pigeon games" )
end

local OldSurvivalGameOneCreate = SurvivalGame.client_onCreate
function SurvivalGame.client_onCreate( self )
	if OldSurvivalGameOnCreate then OldSurvivalGameOnCreate(self) end
	sm.game.bindChatCommand( "/teli", { { "int", "x", true },{ "int", "y", true },{ "int", "z", true },{ "int", "playerID", true } }, "cl_onCustomChatCommand", "teliports player to location" )
	sm.game.bindChatCommand( "/listplayers", {}, "cl_onCustomChatCommand", "teliports player to location" )
	sm.game.bindChatCommand( "/getplayerlocation", {{ "int", "playerID", true }}, "cl_onCustomChatCommand", "get a player's location" )
	
	sm.game.bindChatCommand( "/ammo", { { "int", "quantity", true } }, "cl_onChatCommand", "Give ammo (default 50)" )
	
	sm.game.bindChatCommand( "/spudgun", {}, "cl_onChatCommand", "Give the spudgun" )
	sm.game.bindChatCommand( "/gatling", {}, "cl_onChatCommand", "Give the potato gatling gun" )
	sm.game.bindChatCommand( "/shotgun", {}, "cl_onChatCommand", "Give the fries shotgun" )
	sm.game.bindChatCommand( "/sunshake", {}, "cl_onChatCommand", "Give 1 sunshake" )
	sm.game.bindChatCommand( "/baguette", {}, "cl_onChatCommand", "Give 1 revival baguette" )
	sm.game.bindChatCommand( "/keycard", {}, "cl_onChatCommand", "Give 1 keycard" )
	sm.game.bindChatCommand( "/powercore", {}, "cl_onChatCommand", "Give 1 powercore" )
	sm.game.bindChatCommand( "/components", { { "int", "quantity", true } }, "cl_onChatCommand", "Give <quantity> components (default 10)" )
	sm.game.bindChatCommand( "/glowsticks", { { "int", "quantity", true } }, "cl_onChatCommand", "Give <quantity> components (default 10)" )
	sm.game.bindChatCommand( "/tumble", { { "bool", "enable", true } }, "cl_onChatCommand", "Set tumble state" )
	sm.game.bindChatCommand( "/god", {}, "cl_onChatCommand", "Mechanic characters will take no damage" )
	sm.game.bindChatCommand( "/respawn", {}, "cl_onChatCommand", "Respawn at last bed (or at the crash site)" )
	sm.game.bindChatCommand( "/encrypt", {}, "cl_onChatCommand", "Restrict interactions in all warehouses" )
	sm.game.bindChatCommand( "/decrypt", {}, "cl_onChatCommand", "Unrestrict interactions in all warehouses" )
	sm.game.bindChatCommand( "/limited", {}, "cl_onChatCommand", "Use the limited inventory" )
	sm.game.bindChatCommand( "/unlimited", {}, "cl_onChatCommand", "Use the unlimited inventory" )
	sm.game.bindChatCommand( "/ambush", { { "number", "magnitude", true }, { "int", "wave", true } }, "cl_onChatCommand", "Starts a 'random' encounter" )
	sm.game.bindChatCommand( "/recreate", {}, "cl_onChatCommand", "Recreate world" )
	sm.game.bindChatCommand( "/timeofday", { { "number", "timeOfDay", true } }, "cl_onChatCommand", "Sets the time of the day as a fraction (0.5=mid day)" )
	sm.game.bindChatCommand( "/timeprogress", { { "bool", "enabled", true } }, "cl_onChatCommand", "Enables or disables time progress" )
	sm.game.bindChatCommand( "/day", {}, "cl_onChatCommand", "Disable time progression and set time to daytime" )
	sm.game.bindChatCommand( "/spawn", { { "string", "unitName", true } }, "cl_onChatCommand", "Spawn a unit: 'woc', 'tapebot', 'totebot', 'haybot'" )
	sm.game.bindChatCommand( "/harvestable", { { "string", "harvestableName", true } }, "cl_onChatCommand", "Create a harvestable: 'tree', 'stone'" )
	sm.game.bindChatCommand( "/cleardebug", {}, "cl_onChatCommand", "Clear debug draw objects" )
	sm.game.bindChatCommand( "/export", { { "string", "name", false } }, "cl_onChatCommand", "Exports blueprint $SURVIVAL_DATA/LocalBlueprints/<name>.blueprint" )
	sm.game.bindChatCommand( "/import", { { "string", "name", false } }, "cl_onChatCommand", "Imports blueprint $SURVIVAL_DATA/LocalBlueprints/<name>.blueprint" )
	sm.game.bindChatCommand( "/starterkit", {}, "cl_onChatCommand", "Spawn a starter kit" )
	sm.game.bindChatCommand( "/mechanicstartkit", {}, "cl_onChatCommand", "Spawn a starter kit for starting at mechanic station" )
	sm.game.bindChatCommand( "/pipekit", {}, "cl_onChatCommand", "Spawn a pipe kit" )
	sm.game.bindChatCommand( "/foodkit", {}, "cl_onChatCommand", "Spawn a food kit" )
	sm.game.bindChatCommand( "/seedkit", {}, "cl_onChatCommand", "Spawn a seed kit" )
	sm.game.bindChatCommand( "/die", {}, "cl_onChatCommand", "Kill the player" )
	sm.game.bindChatCommand( "/sethp", { { "number", "hp", false } }, "cl_onChatCommand", "Set player hp value" )
	sm.game.bindChatCommand( "/setwater", { { "number", "water", false } }, "cl_onChatCommand", "Set player water value" )
	sm.game.bindChatCommand( "/setfood", { { "number", "food", false } }, "cl_onChatCommand", "Set player food value" )
	sm.game.bindChatCommand( "/aggroall", {}, "cl_onChatCommand", "All hostile units will be made aware of the player's position" )
	sm.game.bindChatCommand( "/goto", { { "string", "name", false } }, "cl_onChatCommand", "Teleport to predefined position" )
	sm.game.bindChatCommand( "/raid", { { "int", "level", false }, { "int", "wave", true }, { "number", "hours", true } }, "cl_onChatCommand", "Start a level <level> raid at player position at wave <wave> in <delay> hours." )
	sm.game.bindChatCommand( "/stopraid", {}, "cl_onChatCommand", "Cancel all incoming raids" )
	sm.game.bindChatCommand( "/disableraids", { { "bool", "enabled", false } }, "cl_onChatCommand", "Disable raids if true" )
	sm.game.bindChatCommand( "/camera", {}, "cl_onChatCommand", "Spawn a SplineCamera tool" )
	sm.game.bindChatCommand( "/noaggro", { { "bool", "enable", true } }, "cl_onChatCommand", "Toggles the player as a target" )
	sm.game.bindChatCommand( "/killall", {}, "cl_onChatCommand", "Kills all spawned units" )

	sm.game.bindChatCommand( "/printglobals", {}, "cl_onChatCommand", "Print all global lua variables" )
	sm.game.bindChatCommand( "/clearpathnodes", {}, "cl_onChatCommand", "Clear all path nodes in overworld" )
	sm.game.bindChatCommand( "/enablepathpotatoes", { { "bool", "enable", true } }, "cl_onChatCommand", "Creates path nodes at potato hits in overworld and links to previous node" )

	sm.game.bindChatCommand( "/activatequest",  { { "string", "uuid", true } }, "cl_onChatCommand", "Activate quest" )
	sm.game.bindChatCommand( "/completequest",  { { "string", "uuid", true } }, "cl_onChatCommand", "Complete quest" )
end
