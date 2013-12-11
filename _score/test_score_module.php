<?php
/**
 *
 * @package	    Materia
 * @subpackage  scoring
 * @category    Modules
 * @author      ADD NAME HERE
 * 
 * @group App
 * @group Materia
 * @group Score
 * @group Hangman
 */
class Test_Score_Modules_Hangman extends \Basetest
{
	protected function _get_qset($ans1, $ans2, $partial)
	{
		return json_decode('
			{
				"items":[
					{
						"items":[
							{
						 		"name":null,
						 		"type":"QA",
						 		"assets":null,
						 		"answers":[
						 			{
						 				"text":"'.$ans1.'",
						 				"options":{},
						 				"value":"100"
						 			}
						 		],
						 		"questions":[
						 			{
						 				"text":"q1",
						 				"options":{},
						 				"value":""
						 			}
						 		],
						 		"options":{},
						 		"id":0
						 	},
							{
						 		"name":null,
						 		"type":"QA",
						 		"assets":null,
						 		"answers":[
						 			{
						 				"text":"'.$ans2.'",
						 				"options":{},
						 				"value":"100"
						 			}
						 		],
						 		"questions":[
						 			{
						 				"text":"q2",
						 				"options":{},
						 				"value":""
						 			}
						 		],
						 		"options":{},
						 		"id":0
						 	}
						],
						"name":"",
						"options":{},
						"assets":[],
						"rand":false
					}
				],
				 "name":"",
				 "options":
				 	{
				 		"attempts":5,
				 		"partial":'.$partial.'
				 	},
				 "assets":[],
				 "rand":false
			}');
	}

	protected function _make_widget($partial = 'false')
	{
		$this->_asAuthor();

		$title = 'HANGMAN SCORE MODULE TEST';
		$widget_id = $this->_find_widget_id('Hangman');
		$qset = (object) ['version' => 1, 'data' => $this->_get_qset('Ajdklpq90!?', ' !Ajdk lpq-]90', $partial)];
		return \Materia\Api::widget_instance_save($widget_id, $title, $qset, false);
	}

	public function test_check_answer()
	{
		$inst = $this->_make_widget('false');
		$play_session = \Materia\Api::session_play_create($inst->id);
		$qset = \Materia\Api::question_set_get($inst->id, $play_session);

		$log = json_decode('{
			"text":"0,j,9,k,l,d,P,q,a",
			"type":1004,
			"value":0,
			"item_id":"'.$qset->data['items'][0]['items'][0]['id'].'",
			"game_time":10
		}');
		$log2 = json_decode('{
			"text":"A,j,d,l,P,q,9,0",
			"type":1004,
			"value":0,
			"item_id":"'.$qset->data['items'][0]['items'][1]['id'].'",
			"game_time":11
		}');
		$end_log = json_decode('{
			"text":"",
			"type":2,
			"value":"",
			"item_id":0,
			"game_time":12
		}');

		$output = \Materia\Api::play_logs_save($play_session, array($log, $log2, $end_log));

		$scores = \Materia\Api::widget_instance_scores_get($inst->id);

		$this_score = \Materia\Api::widget_instance_play_scores_get($play_session);

		$this->assertInternalType('array', $this_score);
		$this->assertEquals(50, $this_score[0]['overview']['score']);
	}

	public function test_check_answer_partial()
	{
		$inst = $this->_make_widget('true');
		$play_session = \Materia\Api::session_play_create($inst->id);
		$qset = \Materia\Api::question_set_get($inst->id, $play_session);

		$log = json_decode('{
			"text":"A,j,d,k,l,P,q,9,0,U,F,f",
			"type":1004,
			"value":0,
			"item_id":"'.$qset->data['items'][0]['items'][0]['id'].'",
			"game_time":10
		}');
		$log2 = json_decode('{
			"text":"A,j,d,l,P,q,9,0",
			"type":1004,
			"value":0,
			"item_id":"'.$qset->data['items'][0]['items'][1]['id'].'",
			"game_time":11
		}');
		$end_log = json_decode('{
			"text":"",
			"type":2,
			"value":"",
			"item_id":0,
			"game_time":12
		}');

		$output = \Materia\Api::play_logs_save($play_session, array($log, $log2, $end_log));

		$scores = \Materia\Api::widget_instance_scores_get($inst->id);

		$this_score = \Materia\Api::widget_instance_play_scores_get($play_session);

		$this->assertInternalType('array', $this_score);
		$this->assertEquals(94.444444444444, $this_score[0]['overview']['score']);
	}

	public function test_check_answer_failure()
	{
		$inst = $this->_make_widget('true');
		$play_session = \Materia\Api::session_play_create($inst->id);
		$qset = \Materia\Api::question_set_get($inst->id, $play_session);

		$log = json_decode('{
			"text":"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9",
			"type":1004,
			"value":0,
			"item_id":"'.$qset->data['items'][0]['items'][0]['id'].'",
			"game_time":10
		}');
		$log2 = json_decode('{
			"text":"A,j,d,l,P,q,9,0",
			"type":1004,
			"value":0,
			"item_id":"'.$qset->data['items'][0]['items'][1]['id'].'",
			"game_time":11
		}');
		$end_log = json_decode('{
			"text":"",
			"type":2,
			"value":"",
			"item_id":0,
			"game_time":12
		}');

		$output = \Materia\Api::play_logs_save($play_session, array($log, $log2, $end_log));

		$scores = \Materia\Api::widget_instance_scores_get($inst->id);

		$this_score = \Materia\Api::widget_instance_play_scores_get($play_session);

		$this->assertInternalType('array', $this_score);
		$this->assertEquals(72.222222222222, $this_score[0]['overview']['score']);
	}

}
