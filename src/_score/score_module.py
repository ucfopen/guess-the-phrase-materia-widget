from scoring.module import ScoreModule


class Hangman(ScoreModule):
    def __init__(self, play=None):
        super().__init__(play)
        options = self.qset.get("options", {})
        self.wrong_limit = int(options.get("wrong_limit", 6))

        partial_value = str(options.get("partial", False)).lower()
        self.is_partial = partial_value in ("true", "1", "yes")

    def check_answer(self, log):
        question = self.get_question_by_item_id(log.item_id)
        if not question:
            return 0

        answer = self.clean_str(question["answers"][0]["text"])
        answer_size = len(answer)

        submitted = self.clean_str(log.text)

        submitted = submitted[:answer_size + self.wrong_limit - 1]
        missed = len(set(answer) - set(submitted))

        if missed:
            if self.is_partial:
                return round(100 - ((missed / answer_size) * 100))
            else:
                return 0
        return 100

    def clean_str(self, s: str):
        return list({c.lower() for c in s if c.isalnum()})
