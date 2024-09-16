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
    -- self.floor = self.player:getZ()
    self.entry = ISTextEntryBox:new(tostring(self.player:getZ()), 60, 80, 20, getTextManager():getFontHeight(UIFont.Small) + 3 * 2);
    self.entry.font = UIFont.Small;
    self.entry:initialise();
    self.entry:instantiate();
    self.entry:setOnlyNumbers(true);
    self:addChild(self.entry);
end

function ISRemoveItemTool:onSelectedFloor()
-- Fake function
end

local ISRemoveItemTool_prerender_ext = ISRemoveItemTool.prerender
function ISRemoveItemTool:prerender()
    ISRemoveItemTool_prerender_ext(self)
    self:drawText("Z-axis", 55, 50, 1.0, 1.0, 1.0, 1.0, UIFont.Medium)
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
            local zPosText = self.entry:getText()
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
                                    table.insert(itemBuffer, { it = item, square = sq })
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
                    local square = item:getSquare();
                    triggerEvent("OnObjectAboutToBeRemoved", item);
                    square:transmitRemoveItemFromSquare(item);
                end
            end
        end
    end
    if button.internal == "CLOSE" then
        self:destroy();
        return;
    end
end