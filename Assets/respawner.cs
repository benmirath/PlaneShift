using UnityEngine;
using System.Collections;

public class respawner : MonoBehaviour {


	public Transform spawnPoint;

	void OnTriggerEnter (Collider col) {
		if (col.CompareTag ("Player")) {
			HookShot hook = col.GetComponent<HookShot> ();
			if (hook != null) {
				hook.FreeGrapple ();
			}
			col.transform.position = spawnPoint.position;
		}
	}
}
