using UnityEngine;
using System.Collections;

public class portalTrigger : MonoBehaviour {
	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player")) {
			Application.LoadLevel (Application.loadedLevel);
			gameObject.SetActive (false);
		}
	}
}
