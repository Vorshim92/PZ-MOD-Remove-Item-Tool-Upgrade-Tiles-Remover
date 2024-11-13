local coreFontSize = getCore():getOptionFontSize()

local baseWidth = 340
local baseHeight = 150

local widthMultiplier
local heightMultiplier

if coreFontSize == 1 then
    widthMultiplier = 1
    heightMultiplier = 1
elseif coreFontSize == 2 then
    widthMultiplier = 1.1 -- 10% più largo per 1x
    heightMultiplier = 1.2 -- 20% più alto per 1x
elseif coreFontSize == 3 then
    widthMultiplier = 1.25 -- 25% più largo per 2x
    heightMultiplier = 1.35 -- 35% più alto per 2x
elseif coreFontSize == 4 then
    widthMultiplier = 1.5 -- 50% più largo per 3x
    heightMultiplier = 1.6 -- 60% più alto per 3x
elseif coreFontSize == 5 then
    widthMultiplier = 1.75 -- 75% più largo per 4x
    heightMultiplier = 1.8 -- 80% più alto per 4x
end

local adjustedWidth = baseWidth * widthMultiplier
local adjustedHeight = baseHeight * heightMultiplier

AdminContextMenu.onRemoveItemTool = function(playerObj)
    local ui = ISRemoveItemTool:new(0, 0, adjustedWidth, adjustedHeight, playerObj);
    ui:initialise();
    ui:addToUIManager();
end

DebugContextMenu.onRemoveItemTool = function(playerObj)
    local ui = ISRemoveItemTool:new(0, 0, adjustedWidth, adjustedHeight, playerObj);
    ui:initialise();
    ui:addToUIManager();
end



local ISRemoveItemTool_initialise_ext = ISRemoveItemTool.initialise
function ISRemoveItemTool:initialise(...)
print("ISRemoveItemTool:initialise()")
ISRemoveItemTool_initialise_ext (self, ...)
    self.itemType:addOption("Tiles")
    self.itemType.autoWidth = false;
    self.itemType:setWidthToFit()
    self.entry = ISLabel:new(50, 70, 20, tostring(self.player:getZ()), 0.9, 0.75, 0, 1.0, UIFont.Small,true)-- _bLeft==nil and true or _bLeft);
    self.entry:initialise();
    self.entry:instantiate();
    self:addChild(self.entry);
    self.entry.valueLabel = self.player:getZ()

    self.button1p = ISButton:new(50+20+5,62, 16, 16, "", self, ISRemoveItemTool.onClickFloor);
    self.button1p.internal = "B1PLUS";
    self.button1p:initialise();
    self.button1p:instantiate();
    self.button1p.backgroundColor = {r=0, g=0, b=0, a=0.0};
    self.button1p.textColor = {r=1.0, g=0.2, b=0.0, a=0.7}
    self.button1p.backgroundColorMouseOver = {r=0.8, g=0.7, b = 0, a= 0.2 };
	-- self.button1p.borderColor = {r=1.0, g=0.2, b=0.0, a=0.5};
	self.button1p:setImage(getTexture("media/ui/upButton.png"))
    self.button1p:forceImageSize(16, 16)
    self:addChild(self.button1p);

    self.button1m = ISButton:new(50+20+5,82, 16, 16, "", self, ISRemoveItemTool.onClickFloor);
    self.button1m.internal = "B1MINUS";
    self.button1m:initialise();
    self.button1m:instantiate();
    self.button1m.textColor = {r=1.0, g=0.2, b=0.0, a=0.7}
    self.button1m.backgroundColor = {r=0, g=0, b=0, a=0.0};
    self.button1m.backgroundColorMouseOver = {r=0.8, g=0.7, b = 0, a= 0.2 };
	-- self.button1m.borderColor = {r=1.0, g=0.2, b=0.0, a=0.5};
	self.button1m:setImage(getTexture("media/ui/downButton.png"))
    self.button1m:forceImageSize(16, 16)
    self:addChild(self.button1m);

    self.disableFloorCheck = ISTickBox:new(self.entry:getX()+160, self.entry:getY(), 15, 15, "remove-floor", self, nil)
    self.disableFloorCheck.choicesColor = {r=1, g=1, b=1, a=1};
    self.disableFloorCheck.borderColor = {r=1, g=1, b=1, a=0.5};
    self.disableFloorCheck.backgroundColor = {r=0, g=0, b=0, a=0};
    self.disableFloorCheck:initialise();
    self.disableFloorCheck:instantiate()
	self:addChild(self.disableFloorCheck)
    self.disableFloorCheck:addOption("Remove Floor")
    self.disableFloorCheck:setVisible(false)


end

function ISRemoveItemTool:onClickFloor(button)
		local val = self.entry.valueLabel
		local newEval = 0
		if button.internal == "B1PLUS" then
			newEval = val+1
		elseif button.internal == "B1MINUS" then
			newEval = val-1
		end
		if newEval < 0 then newEval = 0 end
        if newEval > 8 then newEval = 8 end
        self.entry.valueLabel = newEval
		self.entry:setName(tostring(self.entry.valueLabel));
end

local ISRemoveItemTool_prerender_ext = ISRemoveItemTool.prerender
function ISRemoveItemTool:prerender()
    ISRemoveItemTool_prerender_ext(self)
    self:drawText("Z-Axis", 45, 35, 1.0, 0.2, 0.0, 0.7, UIFont.Medium)
    self.entry:drawRectStatic(-1, 0, 16, 16, self.entry.backgroundColor.a, self.entry.backgroundColor.r, self.entry.backgroundColor.g, self.entry.backgroundColor.b);
	self.entry:drawRectBorder(-1, 0, 16, 16, self.entry.borderColor.a, self.entry.borderColor.r, self.entry.borderColor.g, self.entry.borderColor.b);
	-- self.entry:drawRectBorder(1, 1, 16-2, 16-2, self.entry.borderColor.a, self.entry.borderColor.r, self.entry.borderColor.g, self.entry.borderColor.b);
    
end

local function vorshimHighlightObject(object)
	if object
	then
		object:setHighlighted(true);
        object:setHighlightColor(1, 0, 0, 1);
	end
end

function ISRemoveItemTool:render()
    if self.entry.valueLabel == 0 and self.itemType:isSelected(3) then
        self.disableFloorCheck:setVisible(true)
    else
        self.disableFloorCheck:setVisible(false)
    end
    if self.selectStart then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        local sq = getCell():getGridSquare(math.floor(xx), math.floor(yy), self.zPos)
        if sq and sq:getFloor() then vorshimHighlightObject(sq:getFloor()) end
    elseif self.selectEnd then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        xx = math.floor(xx)
        yy = math.floor(yy)
        local cell = getCell()
        local x1 = math.min(xx, self.startPos.x)
        local x2 = math.max(xx, self.startPos.x)
        local y1 = math.min(yy, self.startPos.y)
        local y2 = math.max(yy, self.startPos.y)    
        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, self.zPos)
                if sq and sq:getFloor() then vorshimHighlightObject(sq:getFloor()) end
            end
        end
    elseif self.startPos ~= nil and self.endPos ~= nil then
        local cell = getCell()
        local x1 = math.min(self.startPos.x, self.endPos.x)
        local x2 = math.max(self.startPos.x, self.endPos.x)
        local y1 = math.min(self.startPos.y, self.endPos.y)
        local y2 = math.max(self.startPos.y, self.endPos.y)
        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, self.zPos)
                if sq and sq:getFloor() then vorshimHighlightObject(sq:getFloor()) end
            end
        end
    end
end


function ISRemoveItemTool:onClick(button)
    print("ISRemoveItemTool:onClick()")

    if button.internal == "SELECT" then
        self.selectEnd = false
        self.startPos = nil
        self.endPos = nil
        self.selectStart = true
    end
    if button.internal == "REMOVE" then
        if self.startPos ~= nil and self.endPos ~= nil then
            local cell = getCell()
            local x1 = math.min(self.startPos.x, self.endPos.x)
            local x2 = math.max(self.startPos.x, self.endPos.x)
            local y1 = math.min(self.startPos.y, self.endPos.y)
            local y2 = math.max(self.startPos.y, self.endPos.y)
            local zPosText = self.entry:getName()
            local zPos = tonumber(zPosText)  -- Converti il testo in numero
                if not zPos then
                    print("Errore: il valore di zPos non è un numero valido.")
                    return
                end
            local itemBuffer = {}
            for x = x1, x2 do
                for y = y1, y2 do
                    local sq = cell:getGridSquare(x, y, zPos)
                    if sq then
                        if self.itemType:isSelected(1) then
                            if sq:getObjects():size()-1 ~= nil then
                                for i=0, sq:getObjects():size()-1 do
                                    if instanceof(sq:getObjects():get(i), "IsoWorldInventoryObject") then
                                        local item = sq:getObjects():get(i)
                                        table.insert(itemBuffer, { it = item, square = sq })
                                    end
                                end
                            end
                        elseif self.itemType:isSelected(2) then
                            for i=0, sq:getStaticMovingObjects():size()-1 do
                                if instanceof(sq:getStaticMovingObjects():get(i), "IsoDeadBody") then
                                    local item = sq:getStaticMovingObjects():get(i)
                                    table.insert(itemBuffer, { it = item, square = sq })
                                end
                            end
                        elseif self.itemType:isSelected(3) then
                            for i=0, sq:getObjects():size()-1 do
                                if instanceof(sq:getObjects():get(i), "IsoObject") then
                                    local item = sq:getObjects():get(i)
                                    if self.disableFloorCheck:isSelected(1) or (zPos ~= 0 or (zPos == 0 and not item:isFloor())) then
                                        table.insert(itemBuffer, { it = item, square = sq })
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            for i, itemData in ipairs(itemBuffer) do
                local sq = itemData.square
                local item = itemData.it
                if self.itemType:isSelected(1) then
                    sq:transmitRemoveItemFromSquare(item);
                    item:removeFromWorld()
                    item:removeFromSquare()
                    item:setSquare(nil)
                elseif self.itemType:isSelected(2) then
                    sq:removeCorpse(item, false);
                elseif self.itemType:isSelected(3) then
                    -- triggerEvent("OnObjectAboutToBeRemoved", item);
                    sq:transmitRemoveItemFromSquare(item);
                    item:removeFromSquare();
                end
            end
        end
    end
    if button.internal == "CLOSE" then
        self:destroy();
        return;
    end
end

-- thanks to bikini for the help
-- z == 0 and not object:isFloor()

-- square:transmitRemoveItemFromSquare(object);
--             object:removeFromSquare();