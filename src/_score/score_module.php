<?php

namespace Materia;

class Score_Modules_Hangman extends Score_Module
{
	protected $_ss_table_headers = ['Question Score', 'The Question', 'Your Correct Guesses', 'Correct Answer'];

	public function check_answer($log)
	{
		// get qset once for options
		if (empty($this->inst->qset)) $this->inst->get_qset($this->inst->id);

		$wrong_limit = $this->inst->qset->data['options']['attempts'];
		$is_partial  = $this->inst->qset->data['options']['partial'];

		if (isset($this->questions[$log->item_id]))
		{
			$q = $this->questions[$log->item_id];

			$answer = $this->clean_str($q->answers[0]['text']);
			$answer_size = count($answer);

			$submitted = $this->clean_str($log->text);
			$submitted = array_slice($submitted, 0, $answer_size + $wrong_limit - 1);

			$missed = count(array_diff($answer, $submitted));

			// if qset option allows partial scores, calculate
			if ($missed)
			{
				if ($is_partial) return (100 - (($missed / $answer_size) * 100));
				else return 0;
			}
			return 100;
		}
		return 0;
	}

	// Returns an array containing unique alpha numeric values
	private function clean_str($str)
	{
		$str = preg_replace('/[^0-9a-z]/i', '', $str);
		$str = strtolower($str);
		$str = str_split($str);
		$str = array_unique($str);	// should not affect user submissions
		return $str;
	}

}
