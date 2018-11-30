class Score < ApplicationRecord
    def self.avg_score(eid)
        return Score.where(eid: eid).average(:score)
    end
    
    def self.max_score(eid)
        return Score.where(eid: eid).maximum(:score)
        #Score.select('maximum(score)').where(evaluations_id: eid).first
    end
    
    def self.min_score(eid)
        return Score.where(eid: eid).minimum(:score)
        #Score.select('minimum(score)').where(evaluations_id: eid).first
    end
end
