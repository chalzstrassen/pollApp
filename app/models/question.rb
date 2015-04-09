class Question < ActiveRecord::Base
  validates :poll_id, presence: true
  validates :text, presence: true

  belongs_to(
    :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id
  )
  has_many(
    :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id
  )

  has_many(
    :responses,
    through: :answer_choices,
    source: :responses
  )

  def results
    results = {}
    answer_choices.each do |choice|
      results[choice.text] = choice.responses.count
    end

    results
  end

  def opt_results
    results = {}
    answer_choices.includes(:responses).each do |choice|
      results[choice.text] = choice.responses.length
    end

    results
  end

  def sql_results
    self.class.connection.execute(<<-SQL
      SELECT
        answer_choices.*, COUNT(responses.answer_choice_id)
      FROM
        answer_choices
      LEFT OUTER JOIN
        responses ON responses.answer_choice_id = answer_choices.id
      GROUP BY
        answer_choice_id

      SQL
    )
  end

  def ar_results
    results = AnswerChoice
      .select("answer_choices.*, COUNT(responses.answer_choice_id) as response_count")
      .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
      .group("answer_choice_id")

    results.map do |result|
      [result.text, result.response_count]
    end
  end

end
