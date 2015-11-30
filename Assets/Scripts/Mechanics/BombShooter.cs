using UnityEngine;
using System.Collections;

public class BombShooter : MonoBehaviour {

	void Update () {
		if (Input.GetButtonDown ("Fire1")) {
			if (curShot != null) {
				curShot.Trigger ();
			}
			Vector3 direction = aimer.TransformDirection(transform.eulerAngles);
			Vector3 position = aimer.position + (direction * 2f);
			curShot = Instantiate (fastShotPrefab, position, Quaternion.Euler (direction)) as BombShot;
		} 
		if (Input.GetButtonUp ("Fire1")) {
			if (curShot != null) {
				curShot.Trigger ();
			}
		}
//		Camera.main.ViewportToWorldPoint (new Vector2 (0.5, 0.5, 0.)));
	}

	BombShot curShot = null;
	public Transform aimer;
	public BombShot fastShotPrefab;
	public BombShot slowShotPrefab;



}
