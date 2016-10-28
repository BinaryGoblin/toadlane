class FlyAndBuy::AnswerKbaQuestions
	
	attr_accessor :signed_in_user, :client, :fly_buy_profile, :client_user, :kba_ques_details, :user_response

	def initialize(user, fly_buy_profile, kba_details = {})
		@signed_in_user = user
    @kba_ques_details = kba_details
    @fly_buy_profile = fly_buy_profile
    @client = FlyBuyService.get_client
	end

	def process
		kba_answer_process
	end

	private

	def kba_answer_process
		get_user_and_instantiate_user
		answer_kba_questions
	end

	def get_user_and_instantiate_user
    @user_response = client.users.get(user_id: fly_buy_profile.synapse_user_id)

    client_user = FlyBuyService.get_user(
                      oauth_key: nil,
                      fingerprint: fly_buy_profile.encrypted_fingerprint,
                      ip_address: fly_buy_profile.synapse_ip_address,
                      user_id: fly_buy_profile.synapse_user_id
                  )

    oauth_payload = {
      "refresh_token" => user_response['refresh_token'],
      "fingerprint" => fly_buy_profile.encrypted_fingerprint
    }

    oauth_response = client_user.users.refresh(payload: oauth_payload)

    @client_user =  FlyBuyService.get_user(
                      oauth_key: oauth_response["oauth_key"],
                      fingerprint: fly_buy_profile.encrypted_fingerprint,
                      ip_address: fly_buy_profile.synapse_ip_address,
                      user_id: fly_buy_profile.synapse_user_id
                  )
  end
	
	def answer_kba_questions
    if user_response["documents"][0]["virtual_docs"][0]["document_type"] == "TIN"
      kba_payload = {
        'documents' => [{
          'id' => user_response['documents'][0]['id'],
          'virtual_docs' => [{
            'id' => user_response['documents'][0]['virtual_docs'][0]['id'],
            'meta' => {
              'question_set' => {
                'answers' => [
                  { "question_id": 1, "answer_id": kba_ques_details['question_1'].to_i },
                  { "question_id": 2, "answer_id": kba_ques_details['question_2'].to_i },
                  { "question_id": 3, "answer_id": kba_ques_details['question_3'].to_i },
                  { "question_id": 4, "answer_id": kba_ques_details['question_4'].to_i },
                  { "question_id": 5, "answer_id": kba_ques_details['question_5'].to_i }
                ]
              }
            }
          }]
        }]
      }
    elsif user_response["documents"][1]["virtual_docs"][0]["document_type"] == "SSN"
      kba_payload = {
        'documents' => [{
          'id' => user_response['documents'][1]['id'],
          'virtual_docs' => [{
            'id' => user_response['documents'][1]['virtual_docs'][0]['id'],
            'meta' => {
              'question_set' => {
                'answers' => [
                  { "question_id": 1, "answer_id": kba_ques_details['question_1'].to_i },
                  { "question_id": 2, "answer_id": kba_ques_details['question_2'].to_i },
                  { "question_id": 3, "answer_id": kba_ques_details['question_3'].to_i },
                  { "question_id": 4, "answer_id": kba_ques_details['question_4'].to_i },
                  { "question_id": 5, "answer_id": kba_ques_details['question_5'].to_i }
                ]
              }
            }
          }]
        }]
      }
    end

    kba_response = client_user.users.update(payload: kba_payload)

    if kba_response["permission"].present?
      permission_array = kba_response["permission"].split('-')
      if permission_array.include?('SEND') && permission_array.include?('RECEIVE')
        fly_buy_profile.update_attribute(:permission_scope_verified, true)
        fly_buy_profile.update_attribute(:kba_questions, {})
      end
    # elsif kba_response["error"].present? && kba_response["error"]["en"].present?
    #   return kba_response
    end
	end
end