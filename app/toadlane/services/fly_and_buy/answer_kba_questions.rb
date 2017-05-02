module Services
  module FlyAndBuy

    class AnswerKbaQuestions < Base
      attr_reader :user, :answers, :synapse_pay

      def initialize(user, fly_buy_profile, answers = {})
        @user = user
        @answers = answers
        @synapse_pay = SynapsePay.new(fingerprint: fly_buy_profile.encrypted_fingerprint, ip_address: fly_buy_profile.synapse_ip_address)

        super(nil, fly_buy_profile)
      end

      def process
        synapse_user = synapse_pay.user(user_id: fly_buy_profile.synapse_user_id)
        submit_kba_question_answers(synapse_user)

        update_fly_buy_profile(kba_questions: {})
      end

      private

      def submit_kba_question_answers(synapse_user)
        synapse_user.base_documents.each do |base_document|
          virtual_doc = base_document.virtual_documents.find do |doc|
            doc.status == 'SUBMITTED|MFA_PENDING'
          end

          if virtual_doc.present?
            question_set = virtual_doc.question_set

            question_set.each do |question|
              answer = answers.fetch("question_#{question.id}".to_sym).to_i

              question.choice = answer
            end

            virtual_doc.submit_kba
          end
        end
      end
    end
  end
end
