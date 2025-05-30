/*
Copyright © 2021 Doppler <support@doppler.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package models

const JSONMountFormat = "json"
const EnvMountFormat = "env"
const TemplateMountFormat = "template"
const DotNETJSONMountFormat = "dotnet-json"
const EnvNoQuotesFormat = "env-no-quotes"
const DockerFormat = "docker"

var SecretsMountFormats = []string{
	EnvMountFormat,
	JSONMountFormat,
	DotNETJSONMountFormat,
	TemplateMountFormat,
	EnvNoQuotesFormat,
	DockerFormat,
}

var SecretsMountFormatMap = map[string]string{
	EnvMountFormat:        EnvMountFormat,
	JSONMountFormat:       JSONMountFormat,
	DotNETJSONMountFormat: DotNETJSONMountFormat,
	TemplateMountFormat:   TemplateMountFormat,
	EnvNoQuotesFormat:     EnvNoQuotesFormat,
	DockerFormat:          DockerFormat,
}
