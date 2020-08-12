local eventDoneCount = 0
local eventCount = 1
local isPlaying = true
local status = 0

EventHandles =
{
    handleRecodeVedioEvent = function (this, eventCode)
        if eventCode == 1 or eventCode == 2 then
            status = 0
            local feature1 = this:getFeature("FaceMakeupV2_1")
            if(feature1) then
                feature1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,true)
            end 
            local feature2 = this:getFeature("FaceMakeupV2_2")
            if(feature2) then
                feature2:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
            local feature3 = this:getFeature("FaceMakeupV2_3")
            if(feature3) then
                feature3:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
        end
        return true
    end,

    handleEffectEvent = function (this, eventCode)
        if eventCode == 1 or eventCode == 2 then
            status = 0
            local feature1 = this:getFeature("FaceMakeupV2_1")
            if(feature1) then
                feature1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,true)
            end 
            local feature2 = this:getFeature("FaceMakeupV2_2")
            if(feature2) then
                feature2:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
            local feature3 = this:getFeature("FaceMakeupV2_3")
            if(feature3) then
                feature3:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
        end
        return true
    end,

    handleFaceActionEvent = function (this, faceIndex, action)
        
        if(action == 2 and status == 2) then
            status = 0
            local feature1 = this:getFeature("FaceMakeupV2_1")
            if(feature1) then
                feature1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,true)
            end 
            local feature2 = this:getFeature("FaceMakeupV2_2")
            if(feature2) then
                feature2:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
            local feature3 = this:getFeature("FaceMakeupV2_3")
            if(feature3) then
                feature3:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
            return true
        end

        if(action == 2 and status == 1) then
            status = 2
            local feature1 = this:getFeature("FaceMakeupV2_1")
            if(feature1) then
                feature1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
            local feature2 = this:getFeature("FaceMakeupV2_2")
            if(feature2) then
                feature2:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
            end 
            local feature3 = this:getFeature("FaceMakeupV2_3")
            if(feature3) then
                feature3:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,true)
            end 
        else if(action == 2 and status == 0) then
                status = 1
                local feature1 = this:getFeature("FaceMakeupV2_1")
                if(feature1) then
                    feature1:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
                end 
                local feature2 = this:getFeature("FaceMakeupV2_2")
                if(feature2) then
                    feature2:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,true)
                end 
                local feature3 = this:getFeature("FaceMakeupV2_3")
                if(feature3) then
                    feature3:setFeatureStatus(EffectSdk.BEF_FEATURE_STATUS_ENABLED,false)
                end 
            end
        end

    end

}