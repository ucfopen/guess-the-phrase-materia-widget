import React from 'react'
import ReactDOM from 'react-dom'

let title = '';

const ScoreScreenApp = props => {
	return(
		<div>
			<div class="responses">Responses:</div>
			<table>
				<tr>
					<th>Score</th>
					<th>Question</th>
					<th>Your Response</th>
					<th>Correct Answer</th>
				</tr>
			{ props.scoreTable.map((row, i) =>
				<tr>
					<td class="score">{row.score}{row.symbol}</td>
					<td>{row.data[0]}</td>
					<td>{row.data[1]}</td>
					<td>{row.data[2]}</td>
				</tr>
			)}
			</table>
		</div>
	);
};

export default ScoreScreenApp;

const updateDisplay = (qset, scoreTable, title) => {
	ReactDOM.render(
		<ScoreScreenApp
			qset={qset}
			scoreTable={scoreTable}
			title={title}
		/>,
		document.getElementById('root')
	);
};

const materiaCallbacks = {
	start: (instance, qset, scoreTable, isPreview, qsetVersion) => {
		title = instance.name;
		updateDisplay(qset, scoreTable, title);
	},
	update: (qset, scoreTable) => {
		updateDisplay(qset, scoreTable, title);
	}
};

Materia.ScoreCore.start(materiaCallbacks);
Materia.ScoreCore.hideResultsTable();
