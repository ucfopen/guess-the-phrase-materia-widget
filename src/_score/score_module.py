import json

from core.models import WidgetQset
from scoring.module import ScoreModule

class Hangman(ScoreModule):
    def __init__(self, play=None):
        super().__init__(play)
        self.scores = {}

    def check_answer(self, log):
        question = self.get_question_by_item_id(log.item_id)
        answer = question["answers"][0]["text"]
        answer_cleaned = self.clean_str(answer)
        answer_size = len(answer_cleaned)

        user_text = log.text if hasattr(log, "text") else log["text"]
        submitted = self.clean_str(user_text)
        wrong_limit = self.qset.get("options", {}).get("wrong_limit", 6)
        is_partial = self.qset.get("options", {}).get("partial", False)

        submitted = submitted[:answer_size + wrong_limit - 1]
        missed = len(set(answer_cleaned) - set(submitted))

        if missed:
            if is_partial:
                return round(100 - ((missed / answer_size) * 100))
            else:
                return 0
        return 100

    def handle_log_question_answered(self, log):
        item_id = log.item_id
        # # skip duplicates logs
        # if item_id in self.scores:
        #     return

        score = self.check_answer(log)
        self.scores[item_id] = score
        self.total_questions += 1
        self.verified_score += score

    def clean_str(self, s: str):
        return list({c.lower() for c in s if c.isalnum()})

    def get_overview_items(self):
        return [
            {"message": "Points Lost", "value": 100 - self.calculated_percent},
            {"message": "Final Score", "value": self.calculated_percent},
        ]

