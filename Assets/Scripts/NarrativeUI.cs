using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class NarrativeUI : MonoBehaviour {
	public CanvasGroup promptGroup;
	public CanvasGroup narrationGroup;
	public Text textUI;
	
	void Awake () {
		showPrompt = false;
		showNarration = false;
		promptGroup.alpha = 0;
		narrationGroup.alpha = 0;
	}
	
	void OnSceneWasLoaded (int level) {
		showPrompt = false;
		showNarration = false;
		promptGroup.alpha = 0;
		narrationGroup.alpha = 0;
	}
	
	public bool showPrompt;
	public bool showNarration;
	void Update () {
		float speed = 2f;
		float narrationTarget = (showNarration && Input.GetKey (KeyCode.Space)) ? 1 : 0;
		narrationGroup.alpha = Mathf.MoveTowards (narrationGroup.alpha, narrationTarget, speed * Time.deltaTime);
		float promptTarget = (showPrompt && narrationTarget != 1) ? 1 : 0;
		promptGroup.alpha = Mathf.MoveTowards (promptGroup.alpha, promptTarget, speed * Time.deltaTime);
	}	
}
