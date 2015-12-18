using UnityEngine;
using System.Collections;

public class NarrativeTrigger : MonoBehaviour {

	void OnTriggerEnter (Collider hit) {
		Controller2 player = hit.GetComponent<Controller2> ();
		if (player != null) {
			MyGameManager.TogglePromptText (true);
			MyGameManager.ToggleNarrationText (true);
		}
	}
	
	void OnTriggerExit (Collider hit) {
		Controller2 player = hit.GetComponent<Controller2> ();
		if (player != null) {
			MyGameManager.TogglePromptText (false);
			MyGameManager.ToggleNarrationText (false);
		}
	}
}
