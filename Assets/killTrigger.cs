using UnityEngine;
using System.Collections;

public class killTrigger : MonoBehaviour {

	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player")) {
			Application.LoadLevel (Application.loadedLevel);
		}
	}
}
