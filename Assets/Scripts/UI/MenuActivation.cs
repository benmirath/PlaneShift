using UnityEngine;
using System.Collections;

public class MenuActivation : MonoBehaviour {
	public Controller cont;
	float defaultGravity;

	void Start () {
		Time.timeScale = 0;
		cont.enabled = false;
	}

	void Update () {
		if (Input.GetKeyDown (KeyCode.Space)) {
			Time.timeScale = 1;
			cont.enabled = true;
			gameObject.SetActive (false);
			
		}
	}
}
