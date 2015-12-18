using UnityEngine;
using System.Collections;

public class Torchlight : MonoBehaviour {
	[SerializeField] Light lightSource;
	
	[SerializeField] float lightRangeMin = 150;
	[SerializeField] float lightRangeMax = 200;
	[SerializeField] float lightIntensityMin = 3;
	[SerializeField] float lightIntensityMax = 4;
	[SerializeField] Color lightColor1;
	[SerializeField] Color lightColor2;
	
	void Update () {
		lightSource.range = lightRangeMin + Mathf.PingPong (Time.time, lightRangeMax - lightRangeMin);
		lightSource.intensity = lightIntensityMin + Mathf.PingPong (Time.time, lightIntensityMax - lightIntensityMin);
		lightSource.color = Color.Lerp (lightColor1, lightColor2, Mathf.PingPong (Time.time, 1));
	}
}
