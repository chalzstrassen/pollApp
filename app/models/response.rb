
class Response < ActiveRecord::Base
  validates :answer_choice_id, presence: true
  validates :user_id, presence: true
  validate :respondent_has_not_already_answered_question

  belongs_to(
    :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id
  )
  belongs_to(
    :respondent,
    class_name: "User",
    foreign_key: :user_id,
    primary_key: :id
  )

  has_one(
    :question,
    through: :answer_choice,
    source: :question
  )

  has_one(
    :poll,
    through: :question,
    source: :poll
  )

  def sibling_responses
    question.responses.where("responses.id <> ? OR ? IS NULL", self.id, self.id)


    # ("? IS NOT NULL OR (responses.id <> (? IS NOT NULL))",
    #    self.id, self.id, self.id)

    # question.responses.where("? IS NOT NULL AND (responses.id <> ? AND ? IS NOT NULL)",
    #   self.id, self.id, self.id)
    #question.responses.where("responses.id <> ?", self.id.to_i)
    # question.responses.where("responses.id <> NULL")
  end

  private

    def respondent_has_not_already_answered_question
      if sibling_responses.where("user_id = ?", self.user_id).empty?
        true
      else
        errors[:user_id] << "already answered question, don't cheat"
      end

    end
end
