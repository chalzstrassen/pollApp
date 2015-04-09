class User < ActiveRecord::Base
  validates :user_name, uniqueness: true, presence: true

  has_many(
    :authored_polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id
  )

  has_many(
    :responses,
    class_name: "Response",
    foreign_key: :user_id,
    primary_key: :id
  )

  def completed_polls
    Poll.find_by_sql ["
    SELECT
       polls.*,COUNT(DISTINCT questions.id), COUNT(user_responses.user_id)
    FROM
      polls
    JOIN
      questions ON questions.poll_id = polls.id
    JOIN
      answer_choices ON answer_choices.question_id = questions.id
    LEFT OUTER JOIN
      (
        SELECT
          *
        FROM
          responses
        WHERE
          responses.user_id = ?
      ) user_responses
      ON user_responses.answer_choice_id = answer_choices.id
    GROUP BY
      polls.id
    HAVING
      COUNT(DISTINCT questions.id) = COUNT(user_responses.user_id)

    ", self.id]
  end

end
# #---
# -- SELECT
# --   polls.* --, questions.text question_text, questions.id question_ID
# -- FROM
# --   polls
# -- JOIN
# --   questions ON questions.poll_id = polls.id
# -- JOIN
# --   answer_choices ON answer_choices.question_id = questions.id
# -- LEFT OUTER JOIN
# --   responses ON responses.answer_choice_id = answer_choices.id
# -- WHERE
# --   responses.user_id = 1
# -- GROUP BY
# --   questions.id, answer_choices.id, responses.user_id
# -- HAVING
# --   COUNT(questions.id) = COUNT(responses.user_id)
# -- #----
# --
# --
# --
# --
# --
# --
# --
# -- WHERE
# --   (SELECT
# --     COUNT(responses.id) AS questions_answered_count
# --   FROM
# --     polls
# --   JOIN
# --     questions ON questions.poll_id = polls.id
# --   JOIN
# --     answer_choices ON answer_choices.question_id = questions.id
# --   LEFT OUTER JOIN
# --     responses ON responses.answer_choice_id = answer_choices.id
# --   JOIN
# --     users ON users.id = responses.user_id
# --   WHERE
# --     responses.user_id = 2
# --   AND
# --     polls.id = 1
# -- ) =
# -- ( SELECT
# --     COUNT(questions.id) AS questions_count
# --   FROM
# --     polls
# --   LEFT OUTER JOIN
# --     questions ON questions.poll_id = polls.id
# --   WHERE
# --     polls.id = 1
# --
# -- )
# -- #----
# -- SELECT
